class AddRebuildRehabTypeToQueryTool < ActiveRecord::DataMigration
  def up
    most_recent_asset_events_table = QueryAssetClass.find_or_create_by(
        table_name: 'most_recent_asset_events',
        transam_assets_join: "left join query_tool_most_recent_asset_events_for_type_view mraev on mraev.base_transam_asset_id = transam_assets.id left join asset_events as most_recent_asset_events on most_recent_asset_events.id = mraev.asset_event_id left join asset_event_types as mrae_types on most_recent_asset_events.asset_event_type_id = mrae_types.id"
    )

    fields = [
        {
            name: 'vehicle_rebuild_type_id',
            label: 'Rebuild / Rehabilitation Type',
            filter_type: 'text',
            association: {
                table_name: 'vehicle_rebuild_types',
                display_field_name: 'name'
            },
            pairs_with: 'other_vehicle_rebuild_type',
            column_filter: 'mrae_types.class_name',
            column_filter_value: 'RehabilitationUpdateEvent'
        },
        {
            name: 'other_vehicle_rebuild_type',
            label: 'Rebuild / Rehabilitation Type (Other)',
            filter_type: 'text',
            hidden: true,
            column_filter: 'mrae_types.class_name',
            column_filter_value: 'RehabilitationUpdateEvent'
        }
    ]

    fields.each do |f|
      if f[:association]
        qac = QueryAssociationClass.find_or_create_by(f[:association])
      end

      qf = QueryField.find_or_create_by(
          name: f[:name],
          label: f[:label],
          query_category: QueryCategory.find_by(name: 'Life Cycle (Rebuild/Rehabilitation)'),
          query_association_class_id: qac.try(:id),
          filter_type: f[:filter_type],
          pairs_with: f[:pairs_with],
          hidden: f[:hidden],
          column_filter: f[:column_filter],
          column_filter_value: f[:column_filter_value]
      )
      qf.query_asset_classes = [most_recent_asset_events_table]
    end
  end
end