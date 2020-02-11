class AddPeriodLengthAndUnitToQueryTool < ActiveRecord::DataMigration
  def up
    data_table = QueryAssetClass.find_or_create_by(
        table_name: 'track_most_recent_performance_restrictions_period_view',
        transam_assets_join: "LEFT JOIN track_most_recent_performance_restrictions_period_view on track_most_recent_performance_restrictions_period_view.base_transam_asset_id = transam_assets.id"
    )

    fields = [
        {
            name: 'period_length',
            label: 'Period of Time',
            filter_type: 'numeric',
            pairs_with: 'period_length_unit'
        },
        {
            name: 'period_length_unit',
            label: 'Unit',
            filter_type: 'text',
            hidden: true
        }
    ]

    fields.each do |f|
      qf = QueryField.find_or_create_by(
          name: f[:name],
          label: f[:label],
          query_category: QueryCategory.find_by(name: 'Life Cycle (Performance Restriction)'),
          filter_type: f[:filter_type],
          hidden: f[:hidden],
          pairs_with: f[:pairs_with]
      )
      qf.query_asset_classes = [data_table]
    end
  end
end