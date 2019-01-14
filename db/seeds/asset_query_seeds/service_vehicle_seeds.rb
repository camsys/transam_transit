service_vehicles_table = QueryAssetClass.find_or_create_by(
  table_name: 'service_vehicles', 
  transam_assets_join: "LEFT JOIN transit_assets as svta ON svta.id = transam_assets.transam_assetible_id and transam_assets.transam_assetible_type = 'TransitAsset' LEFT JOIN service_vehicles ON service_vehicles.id = svta.transit_assetible_id AND svta.transit_assetible_type = 'ServiceVehicle'"
)

# create view to get dual_fuel_type_name
dual_fuel_types_view_sql = <<-SQL
  CREATE OR REPLACE VIEW dual_fuel_type_view AS
    select dual_fuel_types.id, concat(primary_fuel_types.name, '-', secondary_fuel_types.name) as fuel_type_name, dual_fuel_types.active
    from dual_fuel_types
    left join fuel_types as primary_fuel_types 
    on primary_fuel_types.id = dual_fuel_types.primary_fuel_type_id
    left join fuel_types as secondary_fuel_types 
    on secondary_fuel_types.id = dual_fuel_types.secondary_fuel_type_id;
SQL
ActiveRecord::Base.connection.execute dual_fuel_types_view_sql

category_fields = {
  "Characteristics": [
    {
      name: 'chassis_id',
      label: 'Chassis',
      filter_type: 'multi_select',
      pairs_with: 'other_chassis',
      association: {
        table_name: 'chasses',
        display_field_name: 'name'
      }
    },
    {
      name: 'other_chassis',
      label: 'Chassis (Other)',
      filter_type: 'text',
      hidden: true
    },
    {
      name: 'fuel_type_id',
      label: 'Fuel Type',
      filter_type: 'multi_select',
      pairs_with: 'other_fuel_type',
      association: {
        table_name: 'fuel_types',
        display_field_name: 'name'
      }
    },
    {
      name: 'dual_fuel_type_id',
      label: 'Dual Fuel Type',
      filter_type: 'multi_select',
      association: {
        table_name: 'dual_fuel_type_view',
        display_field_name: 'fuel_type_name'
      }
    },
    {
      name: 'other_fuel_type',
      label: 'Other Fuel Type',
      filter_type: 'text',
      hidden: true
    },
    {
      name: 'vehicle_length',
      label: 'Length',
      filter_type: 'numeric',
      pairs_with: 'vehicle_length_unit'
    },
    {
      name: 'vehicle_length_unit',
      label: 'Length Units',
      filter_type: 'text',
      hidden: true
    },
    {
      name: 'gross_vehicle_weight',
      label: 'Gross Vehicle Weight Ratio (GVWR)',
      filter_type: 'numeric',
      pairs_with: 'gross_vehicle_weight_unit'
    },
    {
      name: 'gross_vehicle_weight_unit',
      label: 'GVWR Units',
      filter_type: 'text',
      hidden: true
    },
    {
      name: 'seating_capacity',
      label: 'Seating Capacity (ambulatory)',
      filter_type: 'numeric'
    },
    {
      name: 'wheelchair_capacity',
      label: 'Wheelchair capacity',
      filter_type: 'numeric'
    },
    {
      name: 'ada_accessible',
      label: 'ADA Accessible',
      filter_type: 'boolean'
    },
    {
      name: 'ramp_manufacturer_id',
      label: 'Lift/Ramp Manufacturer',
      filter_type: 'multi_select',
      pairs_with: 'other_ramp_manufacturer',
      association: {
        table_name: 'ramp_manufacturers',
        display_field_name: 'name'
      }
    },
    {
      name: 'other_ramp_manufacturer',
      label: 'Other Lift/Ramp Manufacturer',
      filter_type: 'text',
      hidden: true
    }
  ],
  "Registration & Title": [
    {
      name: 'license_plate',
      label: 'Plate #',
      filter_type: 'text'
    }
  ]
}

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
      pairs_with: field[:pairs_with]
    )
    qf.query_asset_classes << service_vehicles_table
  end
end