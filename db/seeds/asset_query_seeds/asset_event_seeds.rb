# create most recent asset events view
query_view_sql = <<-SQL
  CREATE OR REPLACE VIEW query_tool_most_recent_asset_events_for_type_view AS
    SELECT
      aet.id AS asset_event_type_id, aet.name AS asset_event_name, Max(ae.created_at) AS asset_event_created_time, ae.base_transam_asset_id, Max(ae.id) AS asset_event_id
    FROM asset_events AS ae
    LEFT JOIN asset_event_types AS aet ON aet.id = ae.asset_event_type_id
    LEFT JOIN transam_assets AS ta  ON ta.id = ae.base_transam_asset_id
    GROUP BY aet.id, ae.base_transam_asset_id;
SQL
ActiveRecord::Base.connection.execute query_view_sql

asset_events_table = QueryAssetClass.find_or_create_by(
  table_name: 'asset_events', 
  transam_assets_join: "left join asset_events on asset_events.transam_asset_id = transam_assets.id left join asset_event_types as ae_types on asset_events.asset_event_type_id = ae_types.id"
)


most_recent_asset_events_table = QueryAssetClass.find_or_create_by(
  table_name: 'most_recent_asset_events', 
  transam_assets_join: "left join query_tool_most_recent_asset_events_for_type_view mraev on mraev.base_transam_asset_id = transam_assets.id left join asset_events as most_recent_asset_events on most_recent_asset_events.id = mraev.asset_event_id left join asset_event_types as mrae_types on most_recent_asset_events.asset_event_type_id = mrae_types.id"
)

asset_event_category_fields = {
  "Life Cycle (Disposition & Transfer)": [
    {
      name: 'disposition_type_id',
      label: 'Disposition Type',
      filter_type: 'multi_select',
      association: {
        table_name: 'disposition_types',
        display_field_name: 'name'
      },
      column_filter: 'ae_types.class_name',
      column_filter_value: 'DispositionUpdateEvent'
    },
    {
      name: 'sales_proceeds',
      label: 'Revenue from Sale',
      filter_type: 'numeric',
      column_filter: 'ae_types.class_name',
      column_filter_value: 'DispositionUpdateEvent'
    }
  ]
}

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
    },
    {
      name: 'avg_daily_use_hours',
      label: 'Avg. Daily Use (hrs)',
      filter_type: 'numeric',
      column_filter: 'mrae_types.class_name',
      column_filter_value: 'VehicleUsageUpdateEvent'
    },
    {
      name: 'avg_daily_passenger_trips',
      label: 'Avg. Daily Passenger Trips',
      filter_type: 'numeric',
      column_filter: 'mrae_types.class_name',
      column_filter_value: 'VehicleUsageUpdateEvent'
    }
  ],
  "Life Cycle (Service Status)": [
    {
      name: 'service_status_type_id',
      label: 'Service Status',
      filter_type: 'multi_select',
      association: {
        table_name: 'service_status_types',
        display_field_name: 'name'
      },
      column_filter: 'mrae_types.class_name',
      column_filter_value: 'ServiceStatusUpdateEvent'
    },
    {
      name: 'out_of_service_status_type_id',
      label: 'Out of Service Status',
      filter_type: 'multi_select',
      association: {
        table_name: 'out_of_service_status_types',
        display_field_name: 'name'
      },
      column_filter: 'mrae_types.class_name',
      column_filter_value: 'ServiceStatusUpdateEvent'
    },
    {
      name: 'fta_emergency_contingency_fleet',
      label: 'Emergency Contingency Fleet',
      filter_type: 'boolean',
      column_filter: 'mrae_types.class_name',
      column_filter_value: 'ServiceStatusUpdateEvent'
    }
  ],
  "Life Cycle (Performance Restriction)": [
    {
      name: 'speed_restriction',
      label: 'Speed Restriction',
      filter_type: 'numeric',
      column_filter: 'mrae_types.class_name',
      column_filter_value: 'PerformanceRestrictionUpdateEvent',
      pairs_with: 'speed_restriction_unit'
    },
    {
      name: 'speed_restriction_unit',
      label: 'Unit',
      filter_type: 'text',
      hidden: true
    },
    {
      name: 'performance_restriction_type_id',
      label: 'Restriction Cause',
      filter_type: 'multi_select',
      association: {
        table_name: 'performance_restriction_types',
        display_field_name: 'name'
      },
      column_filter: 'mrae_types.class_name',
      column_filter_value: 'PerformanceRestrictionUpdateEvent'
    }
  ],
  "Life Cycle (Rebuild/Rehabilitation)": [
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
    },
    {
      name: 'total_cost',
      label: 'Cost of Rebuild/Rehabilitation',
      filter_type: 'numeric',
      column_filter: 'mrae_types.class_name',
      column_filter_value: 'RehabilitationUpdateEvent'
    },
    {
      name: 'extended_useful_life_months',
      label: 'Extend Useful Life by (months)',
      filter_type: 'numeric',
      column_filter: 'mrae_types.class_name',
      column_filter_value: 'RehabilitationUpdateEvent'
    },
    {
      name: 'extended_useful_life_miles',
      label: 'Extend Useful Life by (miles)',
      filter_type: 'numeric',
      column_filter: 'mrae_types.class_name',
      column_filter_value: 'RehabilitationUpdateEvent'
    }
  ],
  "Life Cycle (Operations Metrics)": [
    {
      name: 'avg_cost_per_mile',
      label: 'Avg. Cost per Mile/Kilometer',
      filter_type: 'numeric',
      column_filter: 'mrae_types.class_name',
      column_filter_value: 'OperationsUpdateEvent'
    },
    {
      name: 'avg_miles_per_gallon',
      label: 'Avg. Miles per Gallon/Kilometers per Liter',
      filter_type: 'numeric',
      column_filter: 'mrae_types.class_name',
      column_filter_value: 'OperationsUpdateEvent'
    },
    {
      name: 'annual_maintenance_cost',
      label: 'Annual Maintenance Cost',
      filter_type: 'numeric',
      column_filter: 'mrae_types.class_name',
      column_filter_value: 'OperationsUpdateEvent'
    },
    {
      name: 'annual_insurance_cost',
      label: 'Annual Insurance Cost',
      filter_type: 'numeric',
      column_filter: 'mrae_types.class_name',
      column_filter_value: 'OperationsUpdateEvent'
    }
  ],
  "Life Cycle (Odometer Reading)": [
    {
      name: 'current_mileage',
      label: 'Odometer Reading',
      filter_type: 'numeric',
      column_filter: 'mrae_types.class_name',
      column_filter_value: 'MileageUpdateEvent'
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
  ],
  "Life Cycle (Condition)": [
    {
      name: 'assessed_rating',
      label: 'TERM Condition',
      filter_type: 'numeric',
      column_filter: 'mrae_types.class_name',
      column_filter_value: 'ConditionUpdateEvent'
    },
    {
      name: 'condition_type_id',
      label: 'TERM Ratings',
      filter_type: 'multi_select',
      association: {
        table_name: 'condition_types',
        display_field_name: 'name'
      },
      column_filter: 'mrae_types.class_name',
      column_filter_value: 'ConditionUpdateEvent'
    }
  ],
  "Life Cycle (Location / Storage)": [
    {
      name: 'vehicle_storage_method_type_id',
      label: 'Storage Method',
      filter_type: 'multi_select',
      association: {
        table_name: 'vehicle_storage_method_types',
        display_field_name: 'name'
      },
      column_filter: 'mrae_types.class_name',
      column_filter_value: 'StorageMethodUpdateEvent'
    }
  ],
  "Life Cycle (History Log)": [
    {
      name: 'event_date',
      label: 'Event Date',
      filter_type: 'date'
    },
    {
      name: 'comments',
      label: 'Comments',
      filter_type: 'text'
    }
  ]
}

field_data = {
  "asset_events": asset_event_category_fields,
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
        pairs_with: field[:pairs_with],
        column_filter: field[:column_filter],
        column_filter_value: field[:column_filter_value]
      )
      qf.query_asset_classes << event_table
    end
  end
end
