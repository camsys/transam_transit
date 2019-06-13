class AddPowerSignalAssetQueryFields < ActiveRecord::DataMigration
  def up
    qc = QueryCategory.find_by(name: 'Characteristics')

    # create view to get component_subtype data for following component type
    component_types = [
      {
        name: 'Contact System',
        label: 'Contact System Type'
      },{
        name: 'Structure',
        label: 'Structure Type'
      }
    ]
    component_types.each do |component_type_config|
      component_type_name = component_type_config[:name]
      component_type_name_underscored = component_type_name.parameterize(separator: '_')
      subtype_id_column_name = "#{component_type_name_underscored}_subtype_id"
      view_name = "transit_component_#{component_type_name_underscored}_subtype_view"

      view_sql = <<-SQL
        CREATE OR REPLACE VIEW view_name AS
          select transam_assets.id as transam_asset_id, transit_components.component_subtype_id as subtype_id_column_name from transit_components
          inner join transit_assets on transit_assets.transit_assetible_id = transit_components.id
          and transit_assets.transit_assetible_type = 'TransitComponent'
          inner join transam_assets 
          on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
          left join component_subtypes on transit_components.component_subtype_id = component_subtypes.id
          left join component_types on component_subtypes.parent_id = component_types.id and component_subtypes.parent_type = 'ComponentType'
          where component_types.name = 'component_type_name'
      SQL
      view_sql.sub! 'view_name', view_name
      view_sql.sub! 'subtype_id_column_name', subtype_id_column_name
      view_sql.sub! 'component_type_name', component_type_name

      ActiveRecord::Base.connection.execute view_sql

      # create query asset class
      data_table = QueryAssetClass.find_or_create_by(
        table_name: view_name, 
        transam_assets_join: "LEFT JOIN #{view_name} on #{view_name}.transam_asset_id = transam_assets.id"
      )

      # association table
      qac = QueryAssociationClass.find_or_create_by(table_name: 'component_subtypes', display_field_name: 'name')
      # query field
      qf = QueryField.find_or_create_by(
        name: subtype_id_column_name,
        label: component_type_config[:label],
        filter_type: 'multi_select',
        query_association_class: qac,
        query_category: qc
      )
      qf.query_asset_classes = [data_table]
    end

    # add Voltage / Current Type
    vct_config = {
      name: 'infrastructure_voltage_type_id',
      label: 'Voltage / Current Type',
      filter_type: 'multi_select',
      association: {
        table_name: 'infrastructure_voltage_types',
        display_field_name: 'name'
      }
    }

    qf = QueryField.find_or_create_by(
      name: vct_config[:name], 
      label: vct_config[:label], 
      query_category: qc, 
      query_association_class_id: QueryAssociationClass.find_or_create_by(vct_config[:association]).try(:id),
      filter_type: vct_config[:filter_type]
    )
    qf.query_asset_classes << QueryAssetClass.find_by(table_name: 'transit_components')

  end
end