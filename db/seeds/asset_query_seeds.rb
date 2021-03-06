### Load asset query configurations
puts "======= Loading transit asset query configurations ======="
Dir[TransamTransit::Engine.root.join("db/seeds/asset_query_seeds/*.rb")].each {|file| require file }

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
revenue_vehicles_table = QueryAssetClass.find_by(table_name: 'revenue_vehicles')
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
  query_category: QueryCategory.find_or_create_by(name: 'Registration & Title'), 
  filter_type: 'multi_select',
  query_association_class: QueryAssociationClass.find_by(table_name: 'organizations_with_others_view')
)
other_land_ownership_organization_field = QueryField.find_or_create_by(
  name: 'other_land_ownership_organization', 
  label: 'Land Owner (Other)', 
  hidden: true,
  query_category: QueryCategory.find_or_create_by(name: 'Registration & Title'), 
  filter_type: 'text'
)
land_ownership_organization_id_field.query_asset_classes << [facilities_table, infrastructures_table]
other_land_ownership_organization_field.query_asset_classes << [facilities_table, infrastructures_table]

# Vehicle Usage Codes
# create the view
transam_vehicle_usage_codes_view_sql = <<-SQL
  CREATE OR REPLACE VIEW transam_vehicle_usage_codes_view AS
    select vucae.base_transam_asset_id as transam_asset_id, Max(asset_events_vehicle_usage_codes.vehicle_usage_code_id) as vehicle_usage_code_id from transam_assets
    left join asset_events as vucae on vucae.transam_asset_id = transam_assets.id left join asset_events_vehicle_usage_codes on vucae.id = asset_events_vehicle_usage_codes.asset_event_id 
    group by vucae.base_transam_asset_id;
SQL
ActiveRecord::Base.connection.execute transam_vehicle_usage_codes_view_sql

vucae_table = QueryAssetClass.find_or_create_by(
  table_name: 'transam_vehicle_usage_codes_view', 
  transam_assets_join: "left join transam_vehicle_usage_codes_view on transam_vehicle_usage_codes_view.transam_asset_id = transam_assets.id"
)
vuc_association_table = QueryAssociationClass.find_or_create_by(table_name: 'vehicle_usage_codes', display_field_name: 'name')
vucid_field = QueryField.find_or_create_by(
  name: 'vehicle_usage_code_id', 
  label: 'Vehicle Usage Codes', 
  query_category: QueryCategory.find_or_create_by(name: 'Life Cycle (Usage Codes)'), 
  filter_type: 'multi_select',
  query_association_class: vuc_association_table
)
vucid_field.query_asset_classes << [vucae_table]


# Features (Vehicle, Facility)
# create the asset class view
transit_asset_assets_features_view_sql = <<-SQL
  CREATE OR REPLACE VIEW transit_asset_assets_features_view AS
  SELECT transam_assets.id AS transam_asset_id, facility_features.code AS features_code
  FROM assets_facility_features
  INNER JOIN facility_features ON assets_facility_features.facility_feature_id = facility_features.id
  INNER JOIN facilities ON assets_facility_features.transam_asset_id = facilities.id
  INNER JOIN transit_assets ON transit_assetible_id = facilities.id AND transit_assetible_type = 'Facility'
  INNER JOIN transam_assets ON transam_assetible_id = transit_assets.id AND transam_assetible_type = 'TransitAsset'
  UNION ALL
  SELECT transam_assets.id AS transam_asset_id, vehicle_features.code
  FROM assets_vehicle_features
  INNER JOIN vehicle_features ON assets_vehicle_features.vehicle_feature_id = vehicle_features.id
  INNER JOIN revenue_vehicles ON assets_vehicle_features.transam_asset_id = revenue_vehicles.id
  INNER JOIN service_vehicles ON service_vehiclible_id = revenue_vehicles.id AND service_vehiclible_type = 'RevenueVehicle'
  INNER JOIN transit_assets ON transit_assetible_id = service_vehicles.id AND transit_assetible_type = 'ServiceVehicle'
  INNER JOIN transam_assets ON transam_assetible_id = transit_assets.id AND transam_assetible_type = 'TransitAsset'
SQL
ActiveRecord::Base.connection.execute transit_asset_assets_features_view_sql

# create the association/seed view
transit_asset_features_view_sql = <<-SQL
  CREATE OR REPLACE VIEW transit_asset_features_view AS
    SELECT 'Facility' AS `type`, `id`, `name`, `code`, `active` FROM facility_features
    UNION ALL SELECT 'RevenueVehicle' AS `type`, `id`, `name`, `code`, `active` FROM vehicle_features
SQL
ActiveRecord::Base.connection.execute transit_asset_features_view_sql

features_table = QueryAssetClass.find_or_create_by(
    table_name: 'transit_asset_assets_features_view',
    transam_assets_join: "left join transit_asset_assets_features_view on transit_asset_assets_features_view.transam_asset_id = transam_assets.id"
)
features_association_table = QueryAssociationClass.find_or_create_by(table_name: 'transit_asset_features_view', display_field_name: 'name', id_field_name: 'code')
features_field = QueryField.find_or_create_by(
    name: 'features_code',
    label: 'Features',
    query_category: QueryCategory.find_or_create_by(name: 'Operations'),
    filter_type: 'multi_select',
    query_association_class: features_association_table
)
features_field.query_asset_classes << [features_table]

# component description
component_description_view_sql = <<-SQL
  CREATE OR REPLACE VIEW transit_components_description_view AS
    select transam_assets.id as transam_asset_id, transam_assets.description as transit_component_description from transam_assets
    left join transit_assets on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
    left join transit_components on transit_components.id = transit_assets.transit_assetible_id
    where transit_assets.transit_assetible_type = 'TransitComponent'
SQL
ActiveRecord::Base.connection.execute component_description_view_sql

component_description_table = QueryAssetClass.find_or_create_by(
  table_name: 'transit_components_description_view', 
  transam_assets_join: "left join transit_components_description_view on transit_components_description_view.transam_asset_id = transam_assets.id"
)
component_desc_field = QueryField.find_or_create_by(
  name: 'transit_component_description', 
  label: 'Component / Sub-Component Description', 
  query_category: QueryCategory.find_or_create_by(name: 'Characteristics'), 
  filter_type: 'text'
)
component_desc_field.query_asset_classes << [component_description_table]

location_transam_assets_view_sql = <<-SQL
      CREATE OR REPLACE VIEW location_transam_assets_view AS
      SELECT transam_assets.organization_id, transam_assets.id AS location_id, transam_assets.asset_tag, facilities.facility_name, transam_assets.description,
CONCAT(asset_tag, IF(facility_name IS NOT NULL OR description IS NOT NULL, ' : ', ''), IFNULL(facility_name,description)) AS location_name
FROM transam_assets
INNER JOIN `transit_assets` ON `transam_assets`.`transam_assetible_id` = `transit_assets`.`id` AND `transam_assets`.`transam_assetible_type` = 'TransitAsset'
LEFT JOIN `facilities` ON `transit_assets`.`transit_assetible_id` = `facilities`.`id` AND `transit_assets`.`transit_assetible_type` = 'Facility' 
WHERE transam_assets.id IN (SELECT DISTINCT location_id FROM transam_assets WHERE location_id IS NOT NULL)
SQL
ActiveRecord::Base.connection.execute location_transam_assets_view_sql

parent_transam_assets_view_sql = <<-SQL
      CREATE OR REPLACE VIEW parent_transam_assets_view AS
SELECT transam_assets.organization_id, transam_assets.object_key as parent_id, transam_assets.asset_tag, facilities.facility_name, transam_assets.description,
CONCAT(asset_tag, IF(facility_name IS NOT NULL OR description IS NOT NULL, ' : ', ''), IFNULL(facility_name,description)) AS parent_name
FROM transam_assets
INNER JOIN `transit_assets` ON `transam_assets`.`transam_assetible_id` = `transit_assets`.`id` AND `transam_assets`.`transam_assetible_type` = 'TransitAsset'
LEFT JOIN `facilities` ON `transit_assets`.`transit_assetible_id` = `facilities`.`id` AND `transit_assets`.`transit_assetible_type` = 'Facility'
WHERE transam_assets.id IN (SELECT DISTINCT parent_id FROM transam_assets INNER JOIN `transit_assets` ON `transam_assets`.`transam_assetible_id` = `transit_assets`.`id` AND `transam_assets`.`transam_assetible_type` = 'TransitAsset' WHERE parent_id IS NOT NULL AND fta_asset_category_id != 4)
UNION
SELECT transam_assets.organization_id, transam_assets.object_key as parent_id, transam_assets.asset_tag, NULL, transam_assets.description,
CONCAT(asset_tag, IF(description IS NOT NULL, ' : ', ''), description) AS parent_name
FROM transam_assets
INNER JOIN `transit_assets` ON `transam_assets`.`transam_assetible_id` = `transit_assets`.`id` AND `transam_assets`.`transam_assetible_type` = 'TransitAsset'
INNER JOIN `infrastructures` ON `transit_assets`.`transit_assetible_id` = `infrastructures`.`id` AND `transit_assets`.`transit_assetible_type` = 'Infrastructure'
WHERE transam_assets.id IN (SELECT DISTINCT parent_id FROM transam_assets INNER JOIN `transit_assets` ON `transam_assets`.`transam_assetible_id` = `transit_assets`.`id` AND `transam_assets`.`transam_assetible_type` = 'TransitAsset' WHERE parent_id IS NOT NULL AND fta_asset_category_id = 4)
SQL
ActiveRecord::Base.connection.execute parent_transam_assets_view_sql

infrastructures_object_key_view_sql = <<-SQL
    CREATE OR REPLACE VIEW infrastructures_object_key_view AS
    SELECT DISTINCT infrastructures.id AS id, transam_assets.object_key AS object_key FROM transam_assets INNER JOIN `transit_assets` ON `transam_assets`.`transam_assetible_id` = `transit_assets`.`id` AND `transam_assets`.`transam_assetible_type` = 'TransitAsset' INNER JOIN `infrastructures` ON `transit_assets`.`transit_assetible_id` = `infrastructures`.`id` AND `transit_assets`.`transit_assetible_type` = 'Infrastructure'
SQL

parent_id_transam_assets_view_sql = <<-SQL
      CREATE OR REPLACE VIEW parent_id_transam_assets_view AS
      SELECT transam_assets.id AS id, parents.object_key AS parent_object_key
      FROM transam_assets
      INNER JOIN `transit_assets` ON `transam_assets`.`transam_assetible_id` = `transit_assets`.`id` AND `transam_assets`.`transam_assetible_type` = 'TransitAsset'
      INNER JOIN transam_assets AS parents ON parents.id = transam_assets.parent_id
      WHERE fta_asset_category_id != 4
      UNION
      SELECT transam_assets.id AS id, parents.object_key AS parent_object_key
      FROM transam_assets
      INNER JOIN `transit_assets` ON `transam_assets`.`transam_assetible_id` = `transit_assets`.`id` AND `transam_assets`.`transam_assetible_type` = 'TransitAsset'
      INNER JOIN infrastructures_object_key_view AS parents ON parents.id = transam_assets.parent_id
      WHERE fta_asset_category_id = 4
SQL
ActiveRecord::Base.connection.execute infrastructures_object_key_view_sql
ActiveRecord::Base.connection.execute parent_id_transam_assets_view_sql

location_qac = QueryAssociationClass.find_or_create_by(table_name: 'location_transam_assets_view', id_field_name: 'location_id', display_field_name: 'location_name')
QueryField.find_by(name: 'location_id').update!(query_association_class: location_qac)

parent_qf = QueryField.find_by(name: 'parent_id')
parent_qf.update!(name: 'parent_object_key')
parent_qc = QueryAssetClass.find_or_create_by(table_name: 'parent_id_transam_assets_view', transam_assets_join: 'LEFT JOIN parent_id_transam_assets_view ON parent_id_transam_assets_view.id = transam_assets.id')
parent_qf.query_asset_classes = [parent_qc]