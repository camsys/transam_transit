class AddQueryFieldColumnFilters < ActiveRecord::DataMigration
  def up
    asset_events_table = QueryAssetClass.find_by_table_name('asset_events')
    if asset_events_table
      asset_events_table.update(transam_assets_join: "left join asset_events on asset_events.transam_asset_id = transam_assets.id left join asset_event_types as ae_types on asset_events.asset_event_type_id = ae_types.id")
    end
    
    most_recent_asset_events_table = QueryAssetClass.find_by_table_name('most_recent_asset_events')
    if most_recent_asset_events_table
      most_recent_asset_events_table.update(transam_assets_join: "left join all_assets_most_recent_asset_event_view mraev on mraev.base_transam_asset_id = transam_assets.id left join asset_events as most_recent_asset_events on most_recent_asset_events.id = mraev.asset_event_id left join asset_event_types as mrae_types on most_recent_asset_events.asset_event_type_id = mrae_types.id")
    end

    updates = {
      pcnt_5311_routes: {
        column_filter: 'ae_types.class_name',
        column_filter_value: 'VehicleUsageUpdateEvent'
      },
      disposition_type_id: {
        column_filter: 'ae_types.class_name',
        column_filter_value: 'DispositionUpdateEvent'
      },
      sales_proceeds: {
        column_filter: 'ae_types.class_name',
        column_filter_value: 'DispositionUpdateEvent'
      },
      avg_daily_use_hours: {
        column_filter: 'mrae_types.class_name',
        column_filter_value: 'VehicleUsageUpdateEvent'
      },
      avg_daily_passenger_trips: {
        column_filter: 'mrae_types.class_name',
        column_filter_value: 'VehicleUsageUpdateEvent'
      },
      service_status_type_id: {
        column_filter: 'mrae_types.class_name',
        column_filter_value: 'ServiceStatusUpdateEvent'
      },
      fta_emergency_contingency_fleet: {
        column_filter: 'mrae_types.class_name',
        column_filter_value: 'ServiceStatusUpdateEvent'
      },
      speed_restriction: {
        column_filter: 'mrae_types.class_name',
        column_filter_value: 'PerformanceRestrictionUpdateEvent'
      },
      avg_cost_per_mile: {
        column_filter: 'mrae_types.class_name',
        column_filter_value: 'OperationsUpdateEvent'
      },
      avg_miles_per_gallon: {
        column_filter: 'mrae_types.class_name',
        column_filter_value: 'OperationsUpdateEvent'
      },
      annual_maintenance_cost: {
        column_filter: 'mrae_types.class_name',
        column_filter_value: 'OperationsUpdateEvent'
      },
      annual_insurance_cost: {
        column_filter: 'mrae_types.class_name',
        column_filter_value: 'OperationsUpdateEvent'
      },
      current_mileage: {
        column_filter: 'mrae_types.class_name',
        column_filter_value: 'MileageUpdateEvent'
      },
      assessed_rating: {
        column_filter: 'mrae_types.class_name',
        column_filter_value: 'ConditionUpdateEvent'
      },
      condition_type_id: {
        column_filter: 'mrae_types.class_name',
        column_filter_value: 'ConditionUpdateEvent'
      }
    }

    updates.each do |field_name, config|
      f = QueryField.find_by_name(field_name)
      if f 
        f.update config
      end
    end
  end
end