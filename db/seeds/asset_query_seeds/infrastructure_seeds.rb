infrastructures_table = QueryAssetClass.find_or_create_by(
  table_name: 'infrastructures', 
  transam_assets_join: "LEFT JOIN transit_assets as ita ON ita.id = transam_assets.transam_assetible_id and transam_assets.transam_assetible_type = 'TransitAsset' left join infrastructures ON ita.transit_assetible_id = infrastructures.id and ita.transit_assetible_type = 'Infrastructure'"
)

category_fields = {
  "Identification & Classification": [
    {
      name: 'from_line',
      label: 'Line (from)',
      filter_type: 'text',
      pairs_with: 'segment_unit'
    },
    {
      name: 'from_segment',
      label: 'From',
      filter_type: 'text',
      pairs_with: 'segment_unit'
    },
    {
      name: 'to_line',
      label: 'Line (to)',
      filter_type: 'text',
      pairs_with: 'segment_unit'
    },
    {
      name: 'to_segment',
      label: 'To',
      filter_type: 'text',
      pairs_with: 'segment_unit'
    },
    {
      name: 'segment_unit',
      label: 'Segment Unit',
      filter_type: 'text',
      hidden: true
    },
    {
      name: 'infrastructure_segment_type_id',
      label: 'Segment Type',
      filter_type: 'multi_select',
      association: {
        table_name: 'infrastructure_segment_types',
        display_field_name: 'name'
      }
    },
    {
      name: 'infrastructure_division_id',
      label: 'Main Line / Division',
      filter_type: 'multi_select',
      association: {
        table_name: 'infrastructure_divisions',
        display_field_name: 'name'
      }
    },
    {
      name: 'infrastructure_subdivision_id',
      label: 'Branch / Subdivision',
      filter_type: 'multi_select',
      association: {
        table_name: 'infrastructure_subdivisions',
        display_field_name: 'name'
      }
    },
    {
      name: 'infrastructure_track_id',
      label: 'Track',
      filter_type: 'multi_select',
      association: {
        table_name: 'infrastructure_tracks',
        display_field_name: 'name'
      }
    },
    {
      name: 'num_tracks',
      label: 'Number of Tracks',
      filter_type: 'numeric'
    },
    {
      name: 'direction',
      label: 'Direction',
      filter_type: 'text'
    },
    {
      name: 'location_name',
      label: 'Location',
      filter_type: 'text'
    }
  ],
  "Characteristics": [
    {
      name: 'infrastructure_bridge_type_id',
      label: 'Bridge Type',
      filter_type: 'multi_select',
      association: {
        table_name: 'infrastructure_bridge_types',
        display_field_name: 'name'
      }
    },
    {
      name: 'num_spans',
      label: 'Number of Spans',
      filter_type: 'numeric'
    },
    {
      name: 'num_decks',
      label: 'Number of Decks',
      filter_type: 'numeric'
    },
    {
      name: 'infrastructure_crossing_id',
      label: 'Crossing',
      filter_type: 'multi_select',
      association: {
        table_name: 'infrastructure_crossings',
        display_field_name: 'name'
      }
    }
  ],
  "Geometry": [
    {
      name: 'infrastructure_gauge_type_id',
      label: 'Gauge Type',
      filter_type: 'multi_select',
      association: {
        table_name: 'infrastructure_gauge_types',
        display_field_name: 'name'
      }
    },
    {
      name: 'gauge',
      label: 'Gauge',
      filter_type: 'numeric',
      pairs_with: 'gauge_unit'
    },
    {
      name: 'gauge_unit',
      label: 'Gauge Unit',
      filter_type: 'text',
      hidden: true
    },
    {
      name: 'infrastructure_reference_rail_id',
      label: 'Reference Rail',
      filter_type: 'multi_select',
      association: {
        table_name: 'infrastructure_reference_rails',
        display_field_name: 'name'
      }
    },
    {
      name: 'track_gradient_pcnt',
      label: 'Track Gradient (%)',
      filter_type: 'numeric',
      pairs_with: 'track_gradient_unit'
    },
    {
      name: 'track_gradient_degree',
      label: 'Degree',
      filter_type: 'numeric',
      pairs_with: 'track_gradient_unit'
    },
    {
      name: 'track_gradient',
      label: 'Gradient',
      filter_type: 'numeric',
      pairs_with: 'track_gradient_unit'
    },
    {
      name: 'track_gradient_unit',
      label: 'Unit',
      filter_type: 'text',
      hidden: true
    },
    {
      name: 'horizontal_alignment',
      label: 'Horizontal Alignment',
      filter_type: 'numeric',
      pairs_with: 'horizontal_alignment_unit'
    },
    {
      name: 'horizontal_alignment_unit',
      label: 'Unit',
      filter_type: 'text',
      hidden: true
    },
    {
      name: 'vertical_alignment',
      label: 'Vertical Alignment',
      filter_type: 'numeric',
      pairs_with: 'vertical_alignment_unit'
    },
    {
      name: 'vertical_alignment_unit',
      label: 'Unit',
      filter_type: 'text',
      hidden: true
    },
    {
      name: 'crosslevel',
      label: 'Crosslevel',
      filter_type: 'numeric',
      pairs_with: 'crosslevel_unit'
    },
    {
      name: 'crosslevel_unit',
      label: 'Unit',
      filter_type: 'text',
      hidden: true
    },
    {
      name: 'warp_parameter',
      label: 'Warp Parameter',
      filter_type: 'numeric',
      pairs_with: 'warp_parameter_unit'
    },
    {
      name: 'warp_parameter_unit',
      label: 'Unit',
      filter_type: 'text',
      hidden: true
    },
    {
      name: 'track_curvature',
      label: 'Track Curvature',
      filter_type: 'numeric',
      pairs_with: 'track_curvature_unit'
    },
    {
      name: 'track_curvature_unit',
      label: 'Unit',
      filter_type: 'text',
      hidden: true
    },
    {
      name: 'cant',
      label: 'Cant (Superelvation)',
      filter_type: 'numeric',
      pairs_with: 'cant_unit'
    },
    {
      name: 'cant_unit',
      label: 'Unit',
      filter_type: 'text',
      hidden: true
    },
    {
      name: 'cant_gradient',
      label: 'Cant Gradient (Superelvation Runoff)',
      filter_type: 'numeric',
      pairs_with: 'cant_gradient_unit'
    },
    {
      name: 'cant_gradient_unit',
      label: 'Unit',
      filter_type: 'text',
      hidden: true
    },
    {
      name: 'length',
      label: 'Length',
      filter_type: 'numeric',
      pairs_with: 'length_unit'
    },
    {
      name: 'length_unit',
      label: 'Unit',
      filter_type: 'text',
      hidden: true
    },
    {
      name: 'height',
      label: 'Height',
      filter_type: 'numeric',
      pairs_with: 'height_unit'
    },
    {
      name: 'height_unit',
      label: 'Unit',
      filter_type: 'text',
      hidden: true
    },
    {
      name: 'width',
      label: 'Width (Infrastructure Primary Asset)',
      filter_type: 'numeric',
      pairs_with: 'width_unit'
    },
    {
      name: 'width_unit',
      label: 'Unit',
      filter_type: 'text',
      hidden: true
    }
  ],
  "System": [
    {
      name: 'infrastructure_operation_method_type_id',
      label: 'Method of Operation',
      filter_type: 'multi_select',
      association: {
        table_name: 'infrastructure_operation_method_types',
        display_field_name: 'name'
      } 
    },
    {
      name: 'infrastructure_control_system_type_id',
      label: 'Control System Type',
      filter_type: 'multi_select',
      association: {
        table_name: 'infrastructure_control_system_types',
        display_field_name: 'name'
      } 
    }
  ],
  "Funding": [
    {
      name: 'shared_capital_responsibility_organization_id',
      label: 'Organization with Shared Capital Responsibility',
      filter_type: 'multi_select',
      pairs_with: 'other_shared_capital_responsibility',
      association: {
        table_name: 'organizations',
        display_field_name: 'short_name'
      } 
    },
    {
        name: 'other_shared_capital_responsibility',
        label: 'Organization with Shared Capital Responsibility (Other)',
        filter_type: 'text',
        hidden: true
    }
  ],
  "Operations": [
    {
      name: 'max_permissible_speed',
      label: 'Maximum Permissible Speed',
      filter_type: 'numeric',
      pairs_with: 'max_permissible_speed_unit'
    },
    {
      name: 'max_permissible_speed_unit',
      label: 'Unit (for Full Service Speed)',
      filter_type: 'text',
      hidden: true
    },
    {
      name: 'nearest_city',
      label: 'Nearest City / Town',
      filter_type: 'text'
    },
    {
      name: 'nearest_state',
      label: 'State',
      filter_type: 'text'
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
    qf.query_asset_classes << infrastructures_table
  end
end
