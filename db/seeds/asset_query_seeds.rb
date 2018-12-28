### Load asset query configurations
puts "======= Loading transit asset query configurations ======="

# transit_assets table
QueryAssetClass.find_or_create_by(table_name: 'transit_assets', transam_assets_join: "LEFT JOIN transit_assets ON transit_assets.id = transam_assets.transam_assetible_id and transam_assets.transam_assetible_type = 'TransitAsset'")
# Query Category and fields
transit_assets_category_fields = {
  'Identification & Classification': [
    {
      name: 'fta_asset_category_id',
      label: 'Category',
      filter_type: 'multi_select',
      auto_show: true,
      association: {
        table_name: 'fta_asset_categories',
        display_field_name: 'name'
      }
    },
    {
      name: 'fta_asset_class_id',
      label: 'Class',
      filter_type: 'multi_select',
      association: {
        table_name: 'fta_asset_classes',
        display_field_name: 'name'
      }
    }
  ],

  'Funding': [
    {
      name: 'pcnt_capital_responsibility',
      label: 'Percent Capital Responsibility',
      filter_type: 'numeric'
    }
  ],

  'Procurement & Purchase': [
    {
      name: 'contract_num',
      label: 'Contract / Purchase Order (PO) #',
      filter_type: 'text'
    },
    {
      name: 'contract_type_id',
      label: 'Contract / PO Type',
      filter_type: 'multi_select',
      association: {
        table_name: 'contract_types',
        display_field_name: 'name'
      }
    },
    {
      name: 'has_warranty',
      label: 'Warranty',
      filter_type: 'boolean'
    },
    {
      name: 'warranty_date',
      label: 'Warranty Expiration Date',
      filter_type: 'date'
    }
  ],

  'Operations': [
    {
      name: 'operator_id',
      label: 'Operator',
      filter_type: 'multi_select',
      pairs_with: 'other_operator',
      association: {
        table_name: 'organizations',
        display_field_name: 'short_name'
      }
    },
    {
      name: 'other_operator',
      label: 'Operator (Other)',
      filter_type: 'text',
      hidden: true
    }
  ],
  'Registration & Title': [
    {
      name: 'title_number',
      label: 'Title #',
      filter_type: 'text'
    },
    {
      name: 'title_ownership_organization_id',
      label: 'Title Owner',
      filter_type: 'multi_select',
      pairs_with: 'other_title_ownership_organization',
      association: {
        table_name: 'organizations',
        display_field_name: 'short_name'
      }
    },
    {
      name: 'other_title_ownership_organization',
      label: 'Title Owner (Other)',
      filter_type: 'text',
      hidden: true
    },
    {
      name: 'lienholder_id',
      label: 'Lienholder',
      filter_type: 'multi_select',
      pairs_with: 'other_lienholder',
      association: {
        table_name: 'organizations',
        display_field_name: 'short_name'
      }
    },
    {
      name: 'other_lienholder',
      label: 'Lienholder (Other)',
      filter_type: 'text',
      hidden: true
    }
  ]
}

# transit_asset_types view
# create the view
transit_asset_types_view_sql = <<-SQL
  CREATE OR REPLACE VIEW transit_asset_types_view AS
    SELECT ta.id, concat(ta.fta_type_type, '_', ta.fta_type_id) as fta_type_type_id,concat(COALESCE(fvt.name, ''), COALESCE(fsvt.name, ''), COALESCE(fft.name, ''), COALESCE(fet.name, '')) as fta_type FROM transit_assets as ta 
    left join fta_vehicle_types as fvt on fvt.id = ta.fta_type_id and ta.fta_type_type = 'FtaVehicleType'
    left join fta_support_vehicle_types as fsvt on fsvt.id = ta.fta_type_id and ta.fta_type_type = 'FtaSupportVehicleType'
    left join fta_facility_types as fft on fft.id = ta.fta_type_id and ta.fta_type_type = 'FtaFacilityType'
    left join fta_equipment_types as fet on fet.id = ta.fta_type_id and ta.fta_type_type = 'FtaEquipmentType';
SQL
ActiveRecord::Base.connection.execute transit_asset_types_view_sql

QueryAssetClass.find_or_create_by(table_name: 'transit_asset_types_view', transam_assets_join: "LEFT JOIN transit_asset_types_view ON transit_asset_types_view.id = transam_assets.transam_assetible_id and transam_assets.transam_assetible_type = 'TransitAsset'")
# Query Category and fields
transit_asset_types_category_fields = {
  'Identification & Classification': [
    {
      name: 'fta_type_type_id', # used to query
      label: 'Type',
      display_field: 'fta_type', # used to display
      filter_type: 'multi_select'
    }
  ]
}

# seeding
field_data = {
  transit_assets: transit_assets_category_fields,
  transit_asset_types_view: transit_asset_types_category_fields
}
field_data.each do |table_name, category_fields|
  asset_table = QueryAssetClass.find_by_table_name table_name
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
      qf.query_asset_classes << asset_table
    end
  end
end

# exceptions
# NTD ID
ntd_id_field = QueryField.find_or_create_by(
  name: 'ntd_id', 
  label: 'NTD ID', 
  query_category: QueryCategory.find_or_create_by(name: 'Identification & Classification'), 
  filter_type: 'text'
)

facilities_table = QueryAssetClass.find_or_create_by(table_name: 'facilities', transam_assets_join: "LEFT JOIN transit_assets as fta ON fta.id = transam_assets.transam_assetible_id and transam_assets.transam_assetible_type = 'TransitAsset' LEFT JOIN facilities ON (transam_assets.parent_id > 0 AND facilities.id = transam_assets.parent_id) OR (transam_assets.parent_id IS NULL AND facilities.id = fta.transit_assetible_id) AND fta.transit_assetible_type = 'Facility'")
asset_fleets_table = QueryAssetClass.find_or_create_by(table_name: 'asset_fleets', transam_assets_join: "left join assets_asset_fleets ON assets_asset_fleets.transam_asset_id = transam_assets.id LEFT JOIN asset_fleets ON asset_fleets.id = assets_asset_fleets.asset_fleet_id")

ntd_id_field.query_asset_classes << [facilities_table, asset_fleets_table]

# ESL category
revenue_vehicles_table = QueryAssetClass.find_or_create_by(table_name: 'revenue_vehicles', transam_assets_join: "LEFT JOIN transit_assets as rvta ON rvta.id = transam_assets.transam_assetible_id and transam_assets.transam_assetible_type = 'TransitAsset' left join service_vehicles AS sv ON rvta.transit_assetible_id = sv.id and rvta.transit_assetible_type = 'ServiceVehicle' left join revenue_vehicles on sv.service_vehiclible_id = revenue_vehicles.id and sv.service_vehiclible_type = 'RevenueVehicle'")
esl_association_table = QueryAssociationClass.find_or_create_by(table_name: 'esl_categories', display_field_name: 'name')
esl_field = QueryField.find_or_create_by(
  name: 'esl_category_id', 
  label: 'Estimated Service Life (ESL) Category', 
  query_category: QueryCategory.find_or_create_by(name: 'Identification & Classification'), 
  filter_type: 'multi_select',
  query_association_class: esl_association_table
)
esl_field.query_asset_classes << [facilities_table, revenue_vehicles_table]
