class CombineInfrastructureMeasurementRailCulvertsViews < ActiveRecord::DataMigration
  def up
    # drop old separate views
    self.connection.execute "DROP VIEW if exists infrastructure_measurement_rail_type_view;"
    self.connection.execute "DROP VIEW if exists infrastructure_measurement_culverts_type_view;"

    # delete old query asset classes and fields
    QueryAssetClass.where(table_name: ['infrastructure_measurement_rail_type_view', 'infrastructure_measurement_culverts_type_view']).destroy_all
    QueryField.where(name: ['rail_measurement', 'rail_measurement_unit', 'culverts_measurement', 'culverts_measurement_unit']).destroy_all

    column_name = "rail_culverts_measurement"
    unit_column_name = "rail_culverts_measurement_unit"
    view_name = "infrastructure_measurement_rail_culverts_type_view"
    qc = QueryCategory.find_by(name: 'Characteristics')

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
        where component_types.name in ('Rail', 'Culverts')
    SQL
    view_sql.sub! 'view_name', view_name
    view_sql.sub! 'column_name', column_name
    view_sql.sub! 'unit_column_name', unit_column_name

    ActiveRecord::Base.connection.execute view_sql

    # create query asset class
    data_table = QueryAssetClass.find_or_create_by(
        table_name: view_name,
        transam_assets_join: "LEFT JOIN #{view_name} on #{view_name}.transam_asset_id = transam_assets.id"
    )

    # query field
    qf = QueryField.find_or_create_by(
        name: column_name,
        label: 'Length (Infrastructure Component)',
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
end