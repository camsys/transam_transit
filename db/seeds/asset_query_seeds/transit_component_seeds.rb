transit_component_table = QueryAssetClass.find_or_create_by(
  table_name: 'transit_components', 
  transam_assets_join: "LEFT JOIN transit_assets as tcta ON tcta.id = transam_assets.transam_assetible_id and transam_assets.transam_assetible_type = 'TransitAsset' LEFT JOIN transit_components ON transit_components.id = tcta.transit_assetible_id AND tcta.transit_assetible_type = 'TransitComponent'"
)

category_fields = {
  "Characteristics": [
    {
      name: 'component_type_id',
      label: 'Component Type',
      filter_type: 'multi_select',
      association: {
        table_name: 'component_types',
        display_field_name: 'name'
      }
    },
    {
      name: 'component_subtype_id',
      label: 'Sub-Component Type',
      filter_type: 'multi_select',
      association: {
        table_name: 'component_subtypes',
        display_field_name: 'name'
      }
    },
    {
      name: 'component_element_type_id',
      label: 'Element',
      filter_type: 'multi_select',
      association: {
        table_name: 'component_element_types',
        display_field_name: 'name'
      }
    },
    {
      name: 'infrastructure_measurement',
      label: 'Length (per rail)',
      filter_type: 'numeric',
      pairs_with: 'infrastructure_measurement_unit'
    },
    {
      name: 'infrastructure_measurement_unit',
      label: 'Unit',
      filter_type: 'text',
      hidden: true
    },
    {
      name: 'infrastructure_weight',
      label: 'Weight',
      filter_type: 'numeric',
      pairs_with: 'infrastructure_weight_unit'
    },
    {
      name: 'infrastructure_weight_unit',
      label: 'Unit',
      filter_type: 'text',
      hidden: true
    },
    {
      name: 'infrastructure_diameter',
      label: 'Span / Diameter',
      filter_type: 'numeric',
      pairs_with: 'infrastructure_diameter_unit'
    },
    {
      name: 'infrastructure_diameter_unit',
      label: 'Unit',
      filter_type: 'text',
      hidden: true
    },
    {
      name: 'infrastructure_rail_joining_id',
      label: 'Rail Joining',
      filter_type: 'multi_select',
      association: {
        table_name: 'infrastructure_rail_joinings',
        display_field_name: 'name'
      }
    },
    {
      name: 'infrastructure_cap_material_id',
      label: 'Cap Material',
      filter_type: 'multi_select',
      association: {
        table_name: 'infrastructure_cap_materials',
        display_field_name: 'name'
      }
    },
    {
      name: 'infrastructure_foundation_id',
      label: 'Foundation',
      filter_type: 'multi_select',
      association: {
        table_name: 'infrastructure_foundations',
        display_field_name: 'name'
      }
    }
  ]
}

category_fields.each do |category_name, fields|
  qc = QueryCategory.find_or_create_by(name: category_name)
  fields.each do |field|
    if field[:association]
      qac = QueryAssociationClass.find_or_create_by(field[:association])
    end
    qf = QueryField.find_or_create_by(
      name: field[:name], 
      label: field[:label], 
      query_category: qc, 
      query_association_class_id: qac.try(:id),
      filter_type: field[:filter_type],
      auto_show: field[:auto_show],
      hidden: field[:hidden],
      pairs_with: field[:pairs_with]
    )
    qf.query_asset_classes << transit_component_table
  end
end