### Load asset query configurations
puts "======= Loading transit asset query configurations ======="
Dir["seeds/asset_query_seeds/*.rb"].each {|file| require file }

# exceptions
# NTD ID
ntd_id_field = QueryField.find_or_create_by(
  name: 'ntd_id', 
  label: 'NTD ID', 
  query_category: QueryCategory.find_or_create_by(name: 'Identification & Classification'), 
  filter_type: 'text'
)

facilities_table = QueryAssetClass.find_by(table_name: 'facilities')
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

# land ownership id
infrastructures_table = QueryAssetClass.find_by(table_name: 'infrastructures')
land_ownership_organization_id_field = QueryField.find_or_create_by(
  name: 'land_ownership_organization_id', 
  label: 'Land Owner', 
  pairs_with: 'other_land_ownership_organization',
  query_category: QueryCategory.find_by(name: 'Registration & Title'), 
  filter_type: 'multi_select'
)
other_land_ownership_organization_field = QueryField.find_or_create_by(
  name: 'other_land_ownership_organization', 
  label: 'NTD ID', 
  hidden: true
  query_category: QueryCategory.find_by(name: 'Registration & Title'), 
  filter_type: 'text'
)
land_ownership_organization_id_field.query_asset_classes << [facilities_table, infrastructures_table]
other_land_ownership_organization_field.query_asset_classes << [facilities_table, infrastructures_table]
