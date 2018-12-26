### Load asset query configurations
puts "======= Loading transit asset query configurations ======="

# Query Asset Classes
asset_table = QueryAssetClass.find_or_create_by(table_name: 'transit_assets', transam_assets_join: "LEFT JOIN transit_assets ON transit_assets.id = transam_assets.transam_assetible_id and transam_assets.transam_assetible_type = 'TransitAsset'")

# Query Category and fields
category_fields = {
  'Identification & Classification': [
    {
      name: 'fta_asset_category_id',
      label: 'Category',
      filter_type: 'multi_select',
      association: {
        table_name: 'fta_asset_categories',
        display_field_name: 'name'
      }
    },
    {
      name: 'fta_asset_class_id',
      label: 'Class',
      filter_type: 'multi_select',
      association: {
        table_name: 'fta_asset_classes',
        display_field_name: 'name'
      }
    },
    {
      name: 'fta_type_type',
      label: 'Type',
      filter_type: 'multi_select'
    }
  ],

  'Funding': [
    {
      name: 'pcnt_capital_responsibility',
      label: 'Percent Capital Responsibility',
      filter_type: 'numeric'
    }
  ],

  'Procurement & Purchase': [
    {
      name: 'contract_num',
      label: 'Contract / Purchase Order (PO) #',
      filter_type: 'text'
    },
    {
      name: 'contract_type_id',
      label: 'Contract / PO Type',
      filter_type: 'multi_select',
      association: {
        table_name: 'contract_types',
        display_field_name: 'name'
      }
    },
    {
      name: 'has_warranty',
      label: 'Warranty',
      filter_type: 'boolean'
    },
    {
      name: 'warranty_date',
      label: 'Warranty Expiration Date',
      filter_type: 'date'
    }
  ],

  'Operations': [
    {
      name: 'operator_id',
      label: 'Operator',
      filter_type: 'multi_select',
      pairs_with: 'other_operator',
      association: {
        table_name: 'organizations',
        display_field_name: 'short_name'
      }
    },
    {
      name: 'other_operator',
      label: 'Operator (Other)',
      filter_type: 'text',
      hidden: true
    }
  ],
  'Registration & Title': [
    {
      name: 'title_number',
      label: 'Title #',
      filter_type: 'text'
    },
    {
      name: 'title_ownership_organization_id',
      label: 'Title Owner',
      filter_type: 'multi_select',
      pairs_with: 'other_title_ownership_organization',
      association: {
        table_name: 'organizations',
        display_field_name: 'short_name'
      }
    },
    {
      name: 'other_title_ownership_organization',
      label: 'Title Owner (Other)',
      filter_type: 'text',
      hidden: true
    },
    {
      name: 'lienholder_id',
      label: 'Lienholder',
      filter_type: 'multi_select',
      pairs_with: 'other_lienholder',
      association: {
        table_name: 'organizations',
        display_field_name: 'short_name'
      }
    },
    {
      name: 'other_lienholder',
      label: 'Lienholder (Other)',
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
      hidden: field[:hidden],
      pairs_with: field[:pairs_with]
    )
    qf.query_asset_classes << asset_table
  end
end

