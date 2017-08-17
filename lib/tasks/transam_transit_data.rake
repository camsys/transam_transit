# desc "Explaining what the task does"
# task :transam_transit do
#   # Task goes here
# end
namespace :transam_transit_data do

  task add_early_disposition_requests_bulk_update: :environment do
    unless FileContentType.find_by(builder_name: "TransitEarlyDispositionRequestUpdatesTemplateBuilder").present?
      FileContentType.create!({:active => 1, :name => 'Early Disposition Requests', :class_name => 'EarlyDispositionRequestUpdatesFileHandler', :builder_name => "TransitEarlyDispositionRequestUpdatesTemplateBuilder", :description => 'Worksheet requests early disposition for existing inventory.'})
    end
  end

  desc 'add roles list for org types'
  task add_roles_organization_types: :environment do
    OrganizationType.find_by(class_name: 'Grantor').update!(roles: 'guest,manager')
    OrganizationType.find_by(class_name: 'TransitOperator').update!(roles: 'guest,user,transit_manager')
    OrganizationType.find_by(class_name: 'PlanningPartner').update!(roles: 'guest')
  end

  desc 'add facility rollup asset type/subtype'
  task add_facility_asset_subtypes: :environment do
    parent_policy_id = Policy.where('parent_id IS NULL').pluck(:id).first

    new_types = [
        {name: 'Substructure', description: 'Substructure', class_name: 'Component', display_icon_name: 'fa fa-cogs', map_icon_name: 'blueIcon', active: true},
        {name: 'Shell', description: 'Shell', class_name: 'Component', display_icon_name: 'fa fa-cogs', map_icon_name: 'blueIcon', active: true},
        {name: 'Interior', description: 'Interiors', class_name: 'Component', display_icon_name: 'fa fa-cogs', map_icon_name: 'blueIcon', active: true},
        {name: 'Conveyance', description: 'Conveyance', class_name: 'Component', display_icon_name: 'fa fa-cogs', map_icon_name: 'blueIcon', active: true},
        {name: 'Plumbing', description: 'Plumbing', class_name: 'Component', display_icon_name: 'fa fa-cogs', map_icon_name: 'blueIcon', active: true},
        {name: 'HVAC', description: 'HVAC', class_name: 'Component', display_icon_name: 'fa fa-cogs', map_icon_name: 'blueIcon', active: true},
        {name: 'Fire Protection', description: 'Fire Protection', class_name: 'Component', display_icon_name: 'fa fa-cogs', map_icon_name: 'blueIcon', active: true},
        {name: 'Electrical', description: 'Electrical', class_name: 'Component', display_icon_name: 'fa fa-cogs', map_icon_name: 'blueIcon', active: true},
        {name: 'Site', description: 'Site', class_name: 'Component', display_icon_name: 'fa fa-cogs', map_icon_name: 'blueIcon', active: true}
    ].each do |type|
      if AssetType.find_by(name: type[:name]).nil?
        a = AssetType.create!(type)
        PolicyAssetTypeRule.create(policy_id: parent_policy_id, asset_type_id: a.id, service_life_calculation_type_id: ServiceLifeCalculationType.find_by(name: 'Condition Only').id, replacement_cost_calculation_type_id: CostCalculationType.find_by(name: 'Purchase Price + Interest').id, condition_rollup_calculation_type_id: 1, annual_inflation_rate: 1.1, pcnt_residual_value: 0, condition_rollup_weight: 0 )
      end
    end

    [
        {asset_type: 'Substructure', name: 'All Substructure', description: 'All Substructures', active: true},
        {asset_type: 'Substructure', name: 'Foundation', description: 'Foundations', active: true},
        {asset_type: 'Substructure', name: 'Basement', description: 'Basement', active: true},
        {asset_type: 'Substructure', name: 'Foundation - Wall', description: 'Foundation - Wall', active: true},
        {asset_type: 'Substructure', name: 'Foundation - Column', description: 'Foundation - Column', active: true},
        {asset_type: 'Substructure', name: 'Foundation - Piling', description: 'Foundation - Piling', active: true},
        {asset_type: 'Substructure', name: 'Basement - Materials', description: 'Basement - Materials', active: true},
        {asset_type: 'Substructure', name: 'Basement - Insulation', description: 'Basement - Insulation', active: true},
        {asset_type: 'Substructure', name: 'Basement - Slab', description: 'Basement - Slab', active: true},
        {asset_type: 'Substructure', name: 'Basement - Floor Underpinning', description: 'Basement - Floor Underpinning', active: true},

        {asset_type: 'Shell', name: 'All Shell Structure', description: 'All Structures', active: true},
        {asset_type: 'Shell', name: 'Superstructure', description: 'Superstructure', active: true},
        {asset_type: 'Shell', name: 'Roof', description: 'Roof', active: true},
        {asset_type: 'Shell', name: 'Exterior', description: 'Exterior', active: true},
        {asset_type: 'Shell', name: 'Shell Appurtenance', description: 'Shell Appurtenances', active: true},
        {asset_type: 'Shell', name: 'Superstructure - Column', description: 'Superstructure - Column', active: true},
        {asset_type: 'Shell', name: 'Superstructure - Pillar', description: 'Superstructure - Pillar', active: true},
        {asset_type: 'Shell', name: 'Superstructure - Wall', description: 'Superstructure - Wall', active: true},
        {asset_type: 'Shell', name: 'Roof - Surface', description: 'Roof - Surface', active: true},
        {asset_type: 'Shell', name: 'Roof - Gutters', description: 'Roof - Gutters', active: true},
        {asset_type: 'Shell', name: 'Roof - Eaves', description: 'Roof - Eaves', active: true},
        {asset_type: 'Shell', name: 'Roof - Skylight', description: 'Roof - Skylight', active: true},
        {asset_type: 'Shell', name: 'Roof - Chimney Surroundings', description: 'Roof - Chimney Surroundings', active: true},
        {asset_type: 'Shell', name: 'Exterior - Window', description: 'Exterior - Window', active: true},
        {asset_type: 'Shell', name: 'Exterior - Door', description: 'Exterior - Door', active: true},
        {asset_type: 'Shell', name: 'Exterior - Finishes', description: 'Exterior - Finishes', active: true},
        {asset_type: 'Shell', name: 'Shell Appurtenance - Balcony', description: 'Shell Appurtenance - Balcony', active: true},
        {asset_type: 'Shell', name: 'Shell Appurtenance - Fire Escape', description: 'Shell Appurtenance - Fire Escape', active: true},
        {asset_type: 'Shell', name: 'Shell Appurtenance - Gutter', description: 'Shell Appurtenance - Gutter', active: true},
        {asset_type: 'Shell', name: 'Shell Appurtenance - Downspout', description: 'Shell Appurtenance - Downspout', active: true},

        {asset_type: 'Interior', name: 'All Interior', description: 'All Interior', active: true},
        {asset_type: 'Interior', name: 'Partition', description: 'Partition', active: true},
        {asset_type: 'Interior', name: 'Stairs', description: 'Stairs', active: true},
        {asset_type: 'Interior', name: 'Finishes', description: 'Finishes', active: true},
        {asset_type: 'Interior', name: 'Partition - Wall', description: 'Partition - Wall', active: true},
        {asset_type: 'Interior', name: 'Partition - Door', description: 'Partition - Door', active: true},
        {asset_type: 'Interior', name: 'Partition - Fittings', description: 'Partition - Fittings', active: true},
        {asset_type: 'Interior', name: 'Stairs - Landing', description: 'Stairs - Landing', active: true},
        {asset_type: 'Interior', name: 'Finishes - Wall Materials', description: 'Finishes - Wall Materials', active: true},
        {asset_type: 'Interior', name: 'Finishes - Floor Materials', description: 'Finishes - Floor Materials', active: true},
        {asset_type: 'Interior', name: 'Finishes - Ceiling Materials', description: 'Finishes - Ceiling Materials', active: true},

        {asset_type: 'Conveyance', name: 'All Conveyance', description: 'All Conveyance', active: true},
        {asset_type: 'Conveyance', name: 'Elevator', description: 'Elevator', active: true},
        {asset_type: 'Conveyance', name: 'Escalator', description: 'Escalator', active: true},
        {asset_type: 'Conveyance', name: 'Lift', description: 'Lift', active: true},

        {asset_type: 'Plumbing', name: 'All Plumbing', description: 'All Plumbing', active: true},
        {asset_type: 'Plumbing', name: 'Fixture', description: 'Fixture', active: true},
        {asset_type: 'Plumbing', name: 'Water Distribution', description: 'Water Distribution', active: true},
        {asset_type: 'Plumbing', name: 'Sanitary Waste', description: 'Sanitary Waste', active: true},
        {asset_type: 'Plumbing', name: 'Rain Water Drainage', description: 'Rain Water Drainage', active: true},

        {asset_type: 'HVAC', name: 'HVAC System', description: 'HVAC System', active: true},
        {asset_type: 'HVAC', name: 'Energy Supply', description: 'Energy Supply', active: true},
        {asset_type: 'HVAC', name: 'Heat Generation and Distribution System', description: 'Heat Generation and Distribution System', active: true},
        {asset_type: 'HVAC', name: 'Cooling Generation and Distribution System', description: 'Cooling Generation and Distribution System', active: true},
        {asset_type: 'HVAC', name: 'Instrumentation', description: 'Testing, Balancing, Controls and Instrumentation', active: true},

        {asset_type: 'Fire Protection', name: 'All Fire Protection', description: 'All Fire Protection', active: true},
        {asset_type: 'Fire Protection', name: 'Sprinkler', description: 'Sprinkler', active: true},
        {asset_type: 'Fire Protection', name: 'Standpipes', description: 'Standpipes', active: true},
        {asset_type: 'Fire Protection', name: 'Hydrant', description: 'Hydrant', active: true},
        {asset_type: 'Fire Protection', name: 'Other Fire Protection', description: 'Other Fire Protection', active: true},

        {asset_type: 'Electrical', name: 'All Electrical', description: 'All Electrical', active: true},
        {asset_type: 'Electrical', name: 'Service & Distribution', description: 'Service & Distribution', active: true},
        {asset_type: 'Electrical', name: 'Lighting & Branch Wiring', description: 'Lighting & Branch Wiring', active: true},
        {asset_type: 'Electrical', name: 'Communications & Security', description: 'Communications & Security', active: true},
        {asset_type: 'Electrical', name: 'Other Electrical', description: 'Other Electrical', active: true},
        {asset_type: 'Electrical', name: 'Lighting & Branch Wiring - Interior', description: 'Lighting & Branch Wiring - Interior', active: true},
        {asset_type: 'Electrical', name: 'Lighting & Branch Wiring - Exterior', description: 'Lighting & Branch Wiring - Exterior', active: true},
        {asset_type: 'Electrical', name: 'Lighting Protection', description: 'Lighting Protection', active: true},
        {asset_type: 'Electrical', name: 'Generator', description: 'Generator', active: true},
        {asset_type: 'Electrical', name: 'Emergency Lighting', description: ' Emergency Lighting', active: true},

        {asset_type: 'Site', name: 'All Site', description: 'All Site', active: true},
        {asset_type: 'Site', name: 'Roadways/Driveways', description: 'Roadways/Driveways', active: true},
        {asset_type: 'Site', name: 'Parking', description: 'Parking', active: true},
        {asset_type: 'Site', name: 'Pedestrian Area', description: 'Pedestrian Area', active: true},
        {asset_type: 'Site', name: 'Site Development', description: 'Site Development', active: true},
        {asset_type: 'Site', name: 'Landscaping and Irrigation', description: 'Landscaping and Irrigation', active: true},
        {asset_type: 'Site', name: 'Utilities', description: 'Utilities', active: true},
        {asset_type: 'Site', name: 'Roadways/Driveways - Signage', description: 'Roadways/Driveways - Signage', active: true},
        {asset_type: 'Site', name: 'Roadways/Driveways - Markings', description: 'Roadways/Driveways - Markings', active: true},
        {asset_type: 'Site', name: 'Roadways/Driveways - Equipment', description: 'Roadways/Driveways - Equipment', active: true},
        {asset_type: 'Site', name: 'Parking - Signage', description: 'Parking - Signage', active: true},
        {asset_type: 'Site', name: 'Parking - Markings', description: 'Parking - Markings', active: true},
        {asset_type: 'Site', name: 'Parking - Equipment', description: 'Parking - Equipment', active: true},
        {asset_type: 'Site', name: 'Pedestrian Area - Signage', description: 'Pedestrian Area - Signage', active: true},
        {asset_type: 'Site', name: 'Pedestrian Area - Markings', description: 'Pedestrian Area - Markings', active: true},
        {asset_type: 'Site', name: 'Pedestrian Area - Equipment', description: 'Pedestrian Area - Equipment', active: true},
        {asset_type: 'Site', name: 'Site Development - Fence', description: 'Site Development - Fence', active: true},
        {asset_type: 'Site', name: 'Site Development - Wall', description: 'Site Development - Wall', active: true},

    ].each do |subtype|
      if AssetSubtype.find_by(name: subtype[:name]).nil?
        a = AssetSubtype.new (subtype.except(:asset_type))
        a.asset_type = AssetType.find_by(name: subtype[:asset_type])
        a.save!

        PolicyAssetSubtypeRule.create!(policy_id: parent_policy_id, asset_subtype_id: a.id, min_service_life_months: 120, min_used_purchase_service_life_months: 48, replace_with_new: true, replace_with_leased: false, purchase_replacement_code: 'XX.XX.XX', rehabilitation_code: 'XX.XX.XX')
      end
    end
  end

end