facilities_table = QueryAssetClass.find_or_create_by(
  table_name: 'facilities', 
  transam_assets_join: "LEFT JOIN transit_assets as fta ON fta.id = transam_assets.transam_assetible_id and transam_assets.transam_assetible_type = 'TransitAsset' LEFT JOIN facilities ON facilities.id = fta.transit_assetible_id AND fta.transit_assetible_type = 'Facility'"
)

category_fields = {
  "Identification & Classification": [
    {
      name: 'facility_name',
      label: 'Facility Name',
      filter_type: 'text'
    },
    {
      name: 'address_1',
      label: 'Address 1',
      filter_type: 'text'
    },
    {
      name: 'address_2',
      label: 'Address 2',
      filter_type: 'text'
    },
    {
      name: 'city',
      label: 'City',
      filter_type: 'text'
    },
    {
      name: 'state',
      label: 'State',
      filter_type: 'text'
    },
    {
      name: 'country',
      label: 'Country',
      filter_type: 'text'
    }
  ],
  "Characteristics": [
    {
      name: 'facility_size',
      label: 'Facility Size',
      filter_type: 'numeric',
      pairs_with: 'facility_size_unit'
    },
    {
      name: 'facility_size_unit',
      label: 'Size Units',
      filter_type: 'text',
      hidden: true
    },
    {
      name: 'section_of_larger_facility',
      label: 'Section of a Larger Facility',
      filter_type: 'boolean'
    },
    {
      name: 'num_structures',
      label: 'Number of Structures',
      filter_type: 'numeric'
    },
    {
      name: 'num_floors',
      label: 'Number of Floors',
      filter_type: 'numeric'
    },
    {
      name: 'num_elevators',
      label: 'Number of Elevators',
      filter_type: 'numeric'
    },
    {
      name: 'num_escalators',
      label: 'Number of Escalators',
      filter_type: 'numeric'
    },
    {
      name: 'num_parking_spaces_public',
      label: 'Number of Parking Spots (Public)',
      filter_type: 'numeric'
    },
    {
      name: 'num_parking_spaces_private',
      label: 'Number of Parking Spots (Private)',
      filter_type: 'numeric'
    },
    {
      name: 'lot_size',
      label: 'Lot Size',
      filter_type: 'numeric',
      pairs_with: 'lot_size_unit'
    },
    {
      name: 'lot_size_unit',
      label: 'Size Units',
      filter_type: 'text',
      hidden: true
    }
  ],
  "Operations": [
    {
      name: 'facility_capacity_type_id',
      label: 'Vehicle Capacity',
      filter_type: 'multi_select',
      association: {
        table_name: 'facility_capacity_types',
        display_field_name: 'name'
      }
    },
    {
      name: 'fta_private_mode_type_id',
      label: 'Private Mode',
      filter_type: 'multi_select',
      association: {
        table_name: 'fta_private_mode_types',
        display_field_name: 'name'
      }
    }
  ],
  "Registration & Title": [
    {
      name: 'facility_ownership_organization_id',
      label: 'Facility Owner',
      filter_type: 'multi_select',
      pairs_with: 'other_facility_ownership_organization',
      association: {
        table_name: 'organizations',
        display_field_name: 'name'
      }
    },
    {
      name: 'other_facility_ownership_organization',
      label: 'Facility Owner (Other)',
      filter_type: 'text',
      hidden: true
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
    qf.query_asset_classes << facilities_table
  end
end
