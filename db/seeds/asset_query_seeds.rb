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
  filter_type: 'multi_select'
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

# Facility location
transam_assets_table = QueryAssetClass.find_by(table_name: 'transam_assets')
facility_association_table = QueryAssociationClass.find_or_create_by(table_name: 'facilities', display_field_name: 'facility_name')
facility_location_id_field = QueryField.find_or_create_by(
  name: 'location_id', 
  label: 'Location (list of primary facilities)', 
  query_category: QueryCategory.find_or_create_by(name: 'Life Cycle (Location / Storage)'), 
  filter_type: 'text',
  query_association_class: facility_association_table
)
facility_location_id_field.query_asset_classes << [transam_assets_table]

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

# add view for component_asset_tag
component_asset_tags_view_sql = <<-SQL
  CREATE OR REPLACE VIEW component_asset_tags_view AS
    select 
      transam_assets.id as transam_asset_id, transam_assets.asset_tag as component_id
    from transit_components
    inner join transit_assets on transit_assets.transit_assetible_id = transit_components.id
    and transit_assets.transit_assetible_type = 'TransitComponent'
    inner join transam_assets 
    on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
SQL
ActiveRecord::Base.connection.execute component_asset_tags_view_sql
# create query asset class
component_asset_tags_view_table = QueryAssetClass.find_or_create_by(
  table_name: 'component_asset_tags_view', 
  transam_assets_join: "LEFT JOIN component_asset_tags_view on component_asset_tags_view.transam_asset_id = transam_assets.id"
)

# query field
component_asset_tag_field = QueryField.find_or_create_by(
  name: 'component_id',
  label: 'Component ID',
  filter_type: 'text',
  query_category: QueryCategory.find_or_create_by(name: 'Characteristics')
)
component_asset_tag_field.query_asset_classes = [component_asset_tags_view_table]
