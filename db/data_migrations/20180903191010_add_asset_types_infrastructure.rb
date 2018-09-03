class AddAssetTypesInfrastructure < ActiveRecord::DataMigration
  def up
    AssetSubtype.where(asset_type: AssetType.where(name: 'Infrastructure')).destroy_all

    AssetType.where(name: 'Infrastructure').destroy_all




    infrastructure_asset_types = [

        {name: "Guideway", class_name: "Guideway", display_icon_name: "fa fa-map", map_icon_name: 'blueIcon', description: "Infrastructure placeholder asset type", allow_parent: false, active: true},
        {name: "Power & Signal", class_name: "PowerSignal", display_icon_name: "fa fa-plug", map_icon_name: 'blueIcon', description: "Infrastructure placeholder asset type", allow_parent: false, active: true},
        {name: "Track", class_name: "Track", display_icon_name: "fa fa-train", map_icon_name: 'blueIcon', description: "Infrastructure placeholder asset type", allow_parent: false, active: true},
    ]

    infrastructure_asset_types.each do |asset_type|
      AssetType.create!(asset_type)
    end

    asset_subtypes = [
        ['Track','Tangent (Straight)'],
        ['Track','Curve'],
        ['Track','Transition Curve'],
        ['Track','Special Work Asset'],
        ['Guideway','At-Grade'],
        ['Guideway','At-Grade - Crossing'],
        ['Guideway','Bridge'],
        ['Guideway','Tunnel'],
        ['PowerSignal','Signal Equipment'],
        ['PowerSignal','Signal System']
    ]

    asset_subtypes.each do |subtype|
      AssetSubtype.create!(asset_type: AssetType.find_by(class_name: subtype[0]),name: subtype[1], description: subtype[1], active: true)
    end

    policy = Policy.find_by(organization_id: Grantor.first.id)

    replacement_cost_calculation_type = CostCalculationType.find_by(name: 'Purchase Price + Interest')
    service_life_calculation_type = ServiceLifeCalculationType.find_by(name: 'Age Only')
    condition_rollup_calculation_type = ConditionRollupCalculationType.first

    infrastructure_asset_types.each do |asset_type|
      rule = PolicyAssetTypeRule.new
      rule.policy = policy
      rule.asset_type = AssetType.find_by(class_name: asset_type[:class_name])

      rule.service_life_calculation_type = service_life_calculation_type
      rule.replacement_cost_calculation_type = replacement_cost_calculation_type
      rule.condition_rollup_calculation_type = condition_rollup_calculation_type
      rule.annual_inflation_rate = 1
      rule.pcnt_residual_value = 0

      rule.save!
    end

    [
        {asset_type: 'Track', asset_subtype: 'Tangent (Straight)', min_service_life_months: 360, engineering_design: '12.21.03', purchase_replacement: '12.22.03', lease_replacement: '12.26.03',	purchase_expansion: '12.22.03',	lease_expansion: '12.26.03',	rehabilitation: '12.24.03',	construction: '12.23.03'},
        {asset_type: 'Track', asset_subtype: 'Curve', min_service_life_months: 300, engineering_design: '12.21.03', purchase_replacement: '12.22.03', lease_replacement: '12.26.03',	purchase_expansion: '12.22.03',	lease_expansion: '12.26.03',	rehabilitation: '12.24.03',	construction: '12.23.03'},
        {asset_type: 'Track', asset_subtype: 'Transition Curve', min_service_life_months: 300, engineering_design: '12.21.03', purchase_replacement: '12.22.03', lease_replacement: '12.26.03',	purchase_expansion: '12.22.03',	lease_expansion: '12.26.03',	rehabilitation: '12.24.03',	construction: '12.23.03'},
        {asset_type:  'Track', asset_subtype: 'Special Work Asset', min_service_life_months: 300, engineering_design: '12.21.03', purchase_replacement: '12.22.03', lease_replacement: '12.26.03',	purchase_expansion: '12.22.03',	lease_expansion: '12.26.03',	rehabilitation: '12.24.03',	construction: '12.23.03'},
        {asset_type: 'Guideway', asset_subtype: 'At-Grade', min_service_life_months: 1200, engineering_design: '12.21.06', purchase_replacement: '12.22.06', lease_replacement: '12.26.06',	purchase_expansion: '12.22.06',	lease_expansion: '12.26.06',	rehabilitation: '12.24.06',	construction: '12.23.06'},
        {asset_type: 'Guideway', asset_subtype: 'At-Grade - Crossing', min_service_life_months: 120, engineering_design: '12.21.06', purchase_replacement: '12.22.06', lease_replacement: '12.26.06',	purchase_expansion: '12.22.06',	lease_expansion: '12.26.06',	rehabilitation: '12.24.06',	construction: '12.23.06'},
        {asset_type: 'Guideway', asset_subtype: 'Bridge', min_service_life_months: 1200, engineering_design: '12.21.05', purchase_replacement: '12.22.05', lease_replacement: '12.26.05',	purchase_expansion: '12.22.05',	lease_expansion: '12.26.05',	rehabilitation: '12.24.05',	construction: '12.23.05'},
        {asset_type: 'Guideway', asset_subtype: 'Tunnel', min_service_life_months: 1200, engineering_design: '12.21.04', purchase_replacement: '12.22.04', lease_replacement: '12.26.04',	purchase_expansion: '12.22.04',	lease_expansion: '12.26.04',	rehabilitation: '12.24.04',	construction: '12.23.04'},
        {asset_type: 'Power & Signal', asset_subtype: 'Signal Equipment', min_service_life_months: 180, engineering_design: '12.61.01', purchase_replacement: '12.62.01', lease_replacement: '12.66.01',	purchase_expansion: '12.62.01',	lease_expansion: '12.66.01',	rehabilitation: '12.64.01',	construction: '12.63.01'},
        {asset_type: 'Power & Signal', asset_subtype: 'Signal System', min_service_life_months: 180, engineering_design: '12.61.01', purchase_replacement: '12.62.01', lease_replacement: '12.66.01',	purchase_expansion: '12.62.01',	lease_expansion: '12.66.01',	rehabilitation: '12.64.01',	construction:	'12.63.01'}
    ].each do |rule_row|
      rule = PolicyAssetSubtypeRule.new(:policy => policy, :asset_subtype => AssetSubtype.find_by(name: rule_row[:asset_subtype], asset_type: AssetType.find_by(name: rule_row[:asset_type])))
      rule.min_service_life_months = rule_row[:min_service_life_months]

      rule.replacement_cost = 0
      rule.cost_fy_year = 2018

      rule.replace_with_new = true
      rule.replace_with_leased = false
      rule.min_used_purchase_service_life_months = 0
      rule.lease_length_months = 0

      rule.rehabilitation_service_month = 0
      rule.rehabilitation_labor_cost = 0
      rule.rehabilitation_parts_cost = 0

      rule.extended_service_life_months = 0
      rule.extended_service_life_miles = 0

      # ALIs
      rule.purchase_replacement_code = rule_row[:purchase_replacement]
      rule.lease_replacement_code = rule_row[:lease_expansion]
      rule.purchase_expansion_code = rule_row[:purchase_expansion]
      rule.lease_expansion_code = rule_row[:lease_expansion]
      rule.rehabilitation_code = rule_row[:rehabilitation]
      rule.engineering_design_code = rule_row[:engineering_design]
      rule.construction_code = rule_row[:construction]

      rule.default_rule = true

      rule.save!

    end

  end
end