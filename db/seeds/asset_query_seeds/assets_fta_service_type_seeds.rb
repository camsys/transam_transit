assets_fta_service_type_primary_table = QueryAssetClass.find_or_create_by(
  table_name: 'assets_fta_service_types_primary', 
  transam_assets_join: "LEFT JOIN assets_fta_service_types as assets_fta_service_types_primary ON transam_assets.id = assets_fta_service_types_primary.transam_asset_id and assets_fta_service_types_primary.is_primary = true"
)

primary_category_fields = {
  "Operations": [
    {
      name: 'fta_service_type_id',
      label: 'Service Type (Primary Mode)',
      filter_type: 'multi_select',
      association: {
        table_name: 'fta_service_types',
        display_field_name: 'name'
      }
    }
  ]
}

assets_fta_service_type_support_table = QueryAssetClass.find_or_create_by(
  table_name: 'assets_fta_service_types_support', 
  transam_assets_join: "LEFT JOIN assets_fta_service_types as assets_fta_service_types_support ON transam_assets.id = assets_fta_service_types_support.transam_asset_id and assets_fta_service_types_support.is_primary != true"
)

support_category_fields = {
  "Operations": [
    {
      name: 'fta_service_type_id',
      label: 'Service Type (Supports Another Mode)',
      filter_type: 'multi_select',
      association: {
        table_name: 'fta_service_types',
        display_field_name: 'name'
      }
    }
  ]
}

fields_data = {
  assets_fta_service_types_primary: primary_category_fields,
  assets_fta_service_types_support: assets_fta_service_type_support_table
}

fields_data.each do |table_name, category_fields|
  data_table = QueryAssetClass.find_by_table_name table_name
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
      qf.query_asset_classes << data_table
    end
  end
end
