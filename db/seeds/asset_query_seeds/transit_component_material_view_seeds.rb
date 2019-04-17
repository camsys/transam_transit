qc = QueryCategory.find_by(name: 'Characteristics')

component_types = [
  {
    name: 'Ties',
    label: 'Tie Material'
  },{
    name: 'Surface / Deck',
    label: 'Surface / Deck Material'
  },{
    name: 'Substructure',
    label: 'Substructure Material'
  },{
    name: 'Superstructure',
    label: 'Superstructure Material'
  }
]
component_types.each do |component_type_config|
  component_type_name = component_type_config[:name]
  component_type_name_underscored = component_type_name.parameterize(separator: '_')
  material_type_id_column_name = "#{component_type_name_underscored}_material_type_id"
  view_name = "transit_component_#{component_type_name_underscored}_material_view"

  view_sql = <<-SQL
    CREATE OR REPLACE VIEW view_name AS
      select transam_assets.id as transam_asset_id, transit_components.component_material_id as material_type_id_column_name from transit_components
      inner join transit_assets on transit_assets.transit_assetible_id = transit_components.id
      and transit_assets.transit_assetible_type = 'TransitComponent'
      inner join transam_assets 
      on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
      left join component_types on transit_components.component_type_id = component_types.id
      left join component_materials on component_materials.component_type_id = component_types.id
      where component_types.name = 'component_type_name'
  SQL
  view_sql.sub! 'view_name', view_name
  view_sql.sub! 'material_type_id_column_name', material_type_id_column_name
  view_sql.sub! 'component_type_name', component_type_name

  ActiveRecord::Base.connection.execute view_sql

  # create query asset class
  data_table = QueryAssetClass.find_or_create_by(
    table_name: view_name, 
    transam_assets_join: "LEFT JOIN #{view_name} on #{view_name}.transam_asset_id = transam_assets.id"
  )

  # association table
  qac = QueryAssociationClass.find_or_create_by(table_name: 'component_materials', display_field_name: 'name')
  # query field
  qf = QueryField.find_or_create_by(
    name: material_type_id_column_name,
    label: component_type_config[:label],
    filter_type: 'multi_select',
    query_association_class: qac,
    query_category: qc
  )
  qf.query_asset_classes = [data_table]
end