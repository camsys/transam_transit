class UpdateAssetQueryFields < ActiveRecord::DataMigration
  def up
    # add ZIP code
    id_category = QueryCategory.find_by(name: 'Identification & Classification')
    char_category = QueryCategory.find_by(name: 'Characteristics')
    facilities_table = QueryAssetClass.find_by(table_name: 'facilities')

    zip_field = QueryField.find_or_create_by(name: 'zip',
      label: 'ZIP Code',
      filter_type: 'text',
      query_category: id_category
    )
    zip_field.query_asset_classes = [facilities_table]

    # fix label
    other_lo_field = QueryField.find_by(name: 'other_land_ownership_organization')
    if other_lo_field
      other_lo_field.update label: 'Land Owner (Other)'
    end
    gauge_field = QueryField.find_by(name: 'gauge')
    if gauge_field
      gauge_field.update label: 'Gauge'
    end
    gauge_type_field = QueryField.find_by(name: 'infrastructure_gauge_type_id')
    if gauge_type_field
      gauge_type_field.update label: 'Gauge Type'
    end
    nearest_state_field = QueryField.find_by(name: 'nearest_state')
    if nearest_state_field
      nearest_state_field.update label: 'State'
    end

    # fix field name
    address1_field = QueryField.find_by(name: 'address_1')
    if address1_field
      address1_field.update name: 'address1'
    end
    address2_field = QueryField.find_by(name: 'address_2')
    if address2_field
      address2_field.update name: 'address2'
    end
    type_field = QueryField.find_by(name: 'fta_type_type_id')
    if type_field
      type_field.update display_field: 'fta_type'
    end

    # fix field type
    dir_field = QueryField.find_by(name: 'direction')
    if dir_field
      dir_field.update filter_type: 'multi_select'
    end

    # use same organizations lookup table
    orgs_short_name_table = QueryAssociationClass.find_or_create_by(table_name: 'organizations', display_field_name: 'short_name') # correct one
    orgs_name_table = QueryAssociationClass.find_by(table_name: 'organizations', display_field_name: 'name') # wrong one
    if orgs_name_table
      QueryField.where(query_association_class_id: orgs_name_table.id).update_all(query_association_class_id: orgs_short_name_table.id)
      orgs_name_table.destroy
    end
    org_table = QueryAssociationClass.find_by(table_name: 'organization') # wrong table_name
    if org_table
      QueryField.where(query_association_class_id: org_table.id).update_all(query_association_class_id: orgs_short_name_table.id)
      org_table.destroy
    end

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
      query_category: char_category
    )
    component_asset_tag_field.query_asset_classes = [component_asset_tags_view_table]

  end
end