class QueryToolComponentElementSubtypeSwitchTwo < ActiveRecord::DataMigration
  def up
    # create view for new component subtypes
    view_name = 'transit_component_subtype_measurement_view'
    column_name = 'component_subtype_measurement'
    unit_column_name = 'component_subtype_measurement_unit'
    view_sql = <<-SQL
  CREATE OR REPLACE VIEW transit_component_subtype_measurement_view AS
    select 
      transam_assets.id as transam_asset_id, transit_components.infrastructure_measurement as component_subtype_measurement, 
      transit_components.infrastructure_measurement_unit as component_subtype_measurement_unit
    from transit_components
    inner join transit_assets on transit_assets.transit_assetible_id = transit_components.id
    and transit_assets.transit_assetible_type = 'TransitComponent'
    inner join transam_assets 
    on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
    left join component_subtypes on component_subtypes.id = transit_components.component_subtype_id
    where component_subtypes.name in ('Sub-Ballast', 'Blanket', 'Subgrade')
    SQL

    ActiveRecord::Base.connection.execute view_sql

    old_view_sql = <<-SQL
      DROP VIEW IF EXISTS transit_new_component_subtype_measurement_view
    SQL
    ActiveRecord::Base.connection.execute old_view_sql

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
        query_category: QueryCategory.find_by(name: 'Characteristics'),
        pairs_with: unit_column_name
    )
    qf.query_asset_classes = [data_table]

    uqf = QueryField.find_or_create_by(
        name: unit_column_name,
        label: "Unit",
        filter_type: 'text',
        hidden: true,
        query_category: QueryCategory.find_by(name: 'Characteristics')
    )
    uqf.query_asset_classes = [data_table]

    [{new_component_subtype_measurement: qf}, {new_component_subtype_measurement_unit: uqf}].each do |field|
      field.each do |old_name, nqf|
        oqf = QueryField.find_by(name: old_name)
        SavedQueryField.where(query_field: oqf).each do |sqf|
          sqf.update(query_field: nqf)
          output_fields = sqf.saved_query.ordered_output_field_ids
          if output_fields.include?(oqf.id)
            sqf.saved_query.update(ordered_output_field_ids: output_fields.map{|id| id == oqf.id ? nqf.id : id})
          end
        end

        QueryFilter.where(query_field: oqf).update_all(query_field_id: nqf.id)

        oqf.destroy!
      end
    end
    QueryAssetClass.find_by(table_name: 'transit_new_component_subtype_measurement_view').destroy


  # ----------------------- new component subtypes seed -----------------------------
    QueryField.find_by(name: 'new_component_subtype_id').update!(name: 'component_subtype_id')
    QueryAssociationClass.find_by(table_name: 'new_component_subtypes').update!(table_name: 'component_subtypes')
  # ----------------------- end -----------------------------

# ----------------------- reload component subtype specific views -----------------------------
    require_relative File.join("../seeds/asset_query_seeds", 'transit_component_subtype_view_seeds')
    # ----------------------- end -----------------------------

    # ------------- update parent in component elements -------------
    ComponentElement.where(parent_type: 'ComponentElementType').update_all(parent_type: 'ComponentSubtype')
    # ---------------------------------------------------------------

    # -------- move facility subcomponent subtypes to subtype from now named elements ------
    subtypes = ComponentElement.where(parent_type: 'FtaAssetCategory', parent_id: FtaAssetCategory.find_by(name: 'Facilities').id)
    subtypes.each do |subtype|
      components = FacilityComponent.where(component_element: subtype)
      new = ComponentSubtype.create!(name: subtype.name, active: true)
      components.update_all(component_subtype_id: new.id, component_element_id: nil)
    end

    # ------- combine component subtype query fields ------
    qf = QueryField.where(name: 'component_subtype_id')
    if qf.count == 2
      old = qf.last
      qfilters = QueryFilter.where(query_field: old)
      qfilters.update_all(query_field_id: qf.first.id)

      qfilters.each do |filter|
        new_val =  filter.value.split(',').map{|val| ComponentSubtype.find_by(name: subtypes.find_by(id: val).name).id}.join(',')
        filter.update!(value: new_val)
      end

      SavedQueryField.where(query_field: old).each do |sqf|
        sqf.update(query_field: qf.first)
        output_fields = sqf.saved_query.ordered_output_field_ids
        if output_fields.include?(old.id)
          sqf.saved_query.update(ordered_output_field_ids: output_fields.map{|id| id == old.id ? qf.first.id : id})
        end
      end
      old.destroy
    end
    qf.first.update!(label: 'Sub-Component')

    qac = QueryAssociationClass.where(table_name: 'component_subtypes')
    qac.last.destroy if qac.count == 2

    subtypes.destroy_all

  end
end