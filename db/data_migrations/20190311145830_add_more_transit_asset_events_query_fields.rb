class AddMoreTransitAssetEventsQueryFields < ActiveRecord::DataMigration
  def up
    # first, remove pcnt_5311_routes from asset_events (moving to all_assets_most_recent_asset_event_view based)
    qf = QueryField.find_by_name('pcnt_5311_routes')
    qf.destroy

    # seed new
    most_recent_event_category_fields = {
      "Life Cycle (Vehicle Use Metrics)": [
        {
          name: 'pcnt_5311_routes',
          label: '% 5311 Routes',
          filter_type: 'numeric',
          column_filter: 'mrae_types.class_name',
          column_filter_value: 'VehicleUsageUpdateEvent'
        },
        {
          name: 'avg_daily_use_hours',
          label: 'Avg. Daily Use (hrs)',
          filter_type: 'numeric',
          column_filter: 'mrae_types.class_name',
          column_filter_value: 'VehicleUsageUpdateEvent'
        },
        {
          name: 'avg_daily_use_miles',
          label: 'Avg. Daily Use (miles)',
          filter_type: 'numeric',
          column_filter: 'mrae_types.class_name',
          column_filter_value: 'VehicleUsageUpdateEvent'
        }
      ],
      "Life Cycle (Rebuild/Rehabilitation)": [
        {
          name: 'total_cost',
          label: 'Cost of Rebuild/Rehabilitation',
          filter_type: 'numeric',
          column_filter: 'mrae_types.class_name',
          column_filter_value: 'RehabilitationUpdateEvent'
        }
      ],
      "Life Cycle (Maintenance)": [
        {
          name: 'maintenance_type_id',
          label: 'Maintenance Performed',
          filter_type: 'multi_select',
          association: {
            table_name: 'maintenance_types',
            display_field_name: 'name'
          },
          column_filter: 'mrae_types.class_name',
          column_filter_value: 'MaintenanceUpdateEvent'
        },
        {
          name: 'maintenance_provider_type_id',
          label: 'Maintenance Provider Type',
          filter_type: 'multi_select',
          association: {
            table_name: 'maintenance_provider_types',
            display_field_name: 'name'
          },
          column_filter: 'mrae_types.class_name',
          column_filter_value: 'MaintenanceProviderUpdateEvent'
        }
      ]
    }

    field_data = {
      "most_recent_asset_events": most_recent_event_category_fields
    }

    field_data.each do |table_name, category_fields|
      event_table = QueryAssetClass.find_by_table_name table_name
      category_fields.each do |category_name, fields|
        qc = QueryCategory.find_or_create_by(name: category_name)
        fields.each do |field|
          if field[:association]
            qac = QueryAssociationClass.find_or_create_by(field[:association])
          end
          qf = QueryField.find_or_create_by(
            name: field[:name], 
            label: field[:label], 
            query_category: qc, 
            query_association_class_id: qac.try(:id),
            filter_type: field[:filter_type],
            auto_show: field[:auto_show],
            hidden: field[:hidden],
            column_filter: field[:column_filter],
            column_filter_value: field[:column_filter_value]
          )
          qf.query_asset_classes << event_table
        end
      end
    end
  end
end