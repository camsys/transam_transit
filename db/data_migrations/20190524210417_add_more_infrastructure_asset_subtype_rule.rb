class AddMoreInfrastructureAssetSubtypeRule < ActiveRecord::DataMigration
  def up
  
    rules = [
      {
        asset_subtype: AssetSubtype.find_by_name('Substation'),
        min_service_life_months: 480,
        replacement_cost: 0,
        cost_fy_year: 2018,
        replace_with_new: true,
        replace_with_leased: false,
        min_used_purchase_service_life_months: 0,
        engineering_design_code: '12.51.01',
        purchase_replacement_code: '12.52.01',
        lease_replacement_code: '12.56.01',
        purchase_expansion_code: '12.52.01',
        lease_expansion_code: '12.56.01',
        rehabilitation_code: '12.54.01',
        construction_code: '12.53.01'
      },
      {
        asset_subtype: AssetSubtype.find_by_name('Power Equipment'),
        min_service_life_months: 480,
        replacement_cost: 0,
        cost_fy_year: 2018,
        replace_with_new: true,
        replace_with_leased: false,
        min_used_purchase_service_life_months: 0,
        engineering_design_code: '12.51.01',
        purchase_replacement_code: '12.52.01',
        lease_replacement_code: '12.56.01',
        purchase_expansion_code: '12.52.01',
        lease_expansion_code: '12.56.01',
        rehabilitation_code: '12.54.01',
        construction_code: '12.53.01'
      },
      {
        asset_subtype: AssetSubtype.find_by_name('Drive System'),
        min_service_life_months: 300,
        replacement_cost: 0,
        cost_fy_year: 2018,
        replace_with_new: true,
        replace_with_leased: false,
        min_used_purchase_service_life_months: 0,
        engineering_design_code: '12.51.01',
        purchase_replacement_code: '12.52.01',
        lease_replacement_code: '12.56.01',
        purchase_expansion_code: '12.52.01',
        lease_expansion_code: '12.56.01',
        rehabilitation_code: '12.54.01',
        construction_code: '12.53.01'
      },
      {
        asset_subtype: AssetSubtype.find_by_name('Distribution'),
        min_service_life_months: 300,
        replacement_cost: 0,
        cost_fy_year: 2018,
        replace_with_new: true,
        replace_with_leased: false,
        min_used_purchase_service_life_months: 0,
        engineering_design_code: '12.51.01',
        purchase_replacement_code: '12.52.01',
        lease_replacement_code: '12.56.01',
        purchase_expansion_code: '12.52.01',
        lease_expansion_code: '12.56.01',
        rehabilitation_code: '12.54.01',
        construction_code: '12.53.01'
      }
    ]

    parent_policy = Policy.find_by(parent_id: nil)
    if parent_policy
      rules.each do |rule|
        parent_policy.policy_asset_subtype_rules << PolicyAssetSubtypeRule.new(rule)
      end
    end
  end
end