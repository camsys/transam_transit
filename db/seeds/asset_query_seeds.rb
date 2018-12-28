### Load asset query configurations
puts "======= Loading transit asset query configurations ======="

require_relative File.join("seeds/asset_query_seeds", 'transit_assets_seeds.rb')
require_relative File.join("seeds/asset_query_seeds", 'infrastructure_seeds.rb')

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
