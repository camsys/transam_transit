revenue_vehicles_table = QueryAssetClass.find_or_create_by(
  table_name: 'revenue_vehicles', 
  transam_assets_join: "LEFT JOIN transit_assets as rvta ON rvta.id = transam_assets.transam_assetible_id and transam_assets.transam_assetible_type = 'TransitAsset' LEFT JOIN service_vehicles sv ON sv.id = rvta.transit_assetible_id AND rvta.transit_assetible_type = 'ServiceVehicle' LEFT JOIN revenue_vehicles on revenue_vehicles.id = sv.service_vehiclible_id and sv.service_vehiclible_type = 'RevenueVehicle'"
)

category_seeds = {
  "Characteristics": [
    {
      name: 'standing_capacity',
      label: 'Standing Capacity',
      filter_type: 'numeric'
    }
  ],
  "Funding": [
    {
      name: 'fta_funding_type_id',
      label: 'Funding Type',
      filter_type: 'multi_select',
      association: {
        table_name: 'fta_funding_types',
        display_field_name: 'name'
      }
    },
    {
      name: 'fta_ownership_type_id',
      label: 'Ownership Type',
      filter_type: 'multi_select',
      pairs_with: 'other_fta_ownership_type',
      association: {
        table_name: 'fta_ownership_types',
        display_field_name: 'name'
      }
    },
    {
      name: 'other_fta_ownership_type',
      label: 'Ownership Type (Other)',
      filter_type: 'text',
      hidden: true
    }
  ],
  "Operations": [
    {
      name: 'dedicated',
      label: 'Dedicated Asset',
      filter_type: 'boolean'
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
    qf.query_asset_classes << revenue_vehicles_table
  end
end