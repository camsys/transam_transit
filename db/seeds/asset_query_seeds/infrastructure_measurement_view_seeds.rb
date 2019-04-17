qc = QueryCategory.find_by(name: 'Characteristics')

# create view for following component type
component_types = [
  {
    name: 'Rail',
    label: 'Length (per rail)'
  },{
    name: 'Culverts',
    label: 'Length (Infra. Component)'
  }
]
component_types.each do |component_type_config|
  component_type_name = component_type_config[:name]
  component_type_name_underscored = component_type_name.parameterize(separator: '_')
  column_name = "#{component_type_name_underscored}_measurement"
  unit_column_name = "#{component_type_name_underscored}_measurement_unit"
  view_name = "infrastructure_measurement_#{component_type_name_underscored}_type_view"

  view_sql = <<-SQL
    CREATE OR REPLACE VIEW view_name AS
      select 
        transam_assets.id as transam_asset_id, transit_components.infrastructure_measurement as column_name, 
        transit_components.infrastructure_measurement_unit as unit_column_name
      from transit_components
      inner join transit_assets on transit_assets.transit_assetible_id = transit_components.id
      and transit_assets.transit_assetible_type = 'TransitComponent'
      inner join transam_assets 
      on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
      left join component_types on component_types.id = transit_components.component_type_id
      where component_types.name = 'component_type_name'
  SQL
  view_sql.sub! 'view_name', view_name
  view_sql.sub! 'column_name', column_name
  view_sql.sub! 'unit_column_name', unit_column_name
  view_sql.sub! 'component_type_name', component_type_name

  ActiveRecord::Base.connection.execute view_sql

  # create query asset class
  data_table = QueryAssetClass.find_or_create_by(
    table_name: view_name, 
    transam_assets_join: "LEFT JOIN #{view_name} on #{view_name}.transam_asset_id = transam_assets.id"
  )

  # query field
  qf = QueryField.find_or_create_by(
    name: column_name,
    label: component_type_config[:label],
    filter_type: 'numeric',
    query_category: qc,
    pairs_with: unit_column_name
  )
  qf.query_asset_classes = [data_table]

  uqf = QueryField.find_or_create_by(
    name: unit_column_name,
    label: "Unit",
    filter_type: 'text',
    hidden: true,
    query_category: qc
  )
  uqf.query_asset_classes = [data_table]
end

# create view for component elements
view_name = 'transit_components_element_measurement_view'
column_name = 'component_element_measurement'
unit_column_name = 'component_element_measurement_unit'
view_sql = <<-SQL
  CREATE OR REPLACE VIEW transit_components_element_measurement_view AS
    select 
      transam_assets.id as transam_asset_id, transit_components.infrastructure_measurement as component_element_measurement, 
      transit_components.infrastructure_measurement_unit as component_element_measurement_unit
    from transit_components
    inner join transit_assets on transit_assets.transit_assetible_id = transit_components.id
    and transit_assets.transit_assetible_type = 'TransitComponent'
    inner join transam_assets 
    on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
    left join component_element_types on component_element_types.id = transit_components.component_element_type_id
    where component_element_types.name in ('Sub-Ballast', 'Blanket', 'Subgrade')
SQL

ActiveRecord::Base.connection.execute view_sql

# create query asset class
data_table = QueryAssetClass.find_or_create_by(
  table_name: view_name, 
  transam_assets_join: "LEFT JOIN #{view_name} on #{view_name}.transam_asset_id = transam_assets.id"
)

# query field
qf = QueryField.find_or_create_by(
  name: column_name,
  label: 'Thickness',
  filter_type: 'numeric',
  query_category: qc,
  pairs_with: unit_column_name
)
qf.query_asset_classes = [data_table]

uqf = QueryField.find_or_create_by(
  name: unit_column_name,
  label: "Unit",
  filter_type: 'text',
  hidden: true,
  query_category: qc
)
uqf.query_asset_classes = [data_table]
