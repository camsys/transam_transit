require 'rails_helper'

describe "policies/_asset_subtype_rule_form.html.haml", :type => :view do
  it 'fields' do
    allow(controller).to receive(:current_user).and_return(create(:manager))
    test_policy = create(:policy)
    assign(:rule, PolicyAssetSubtypeRule.new(:policy => test_policy, :asset_subtype_id => 1))
    assign(:policy, test_policy)
    assign(:asset_type, AssetType.first)
    assign(:valid_types, [])
    render

    expect(rendered).to have_field('policy_asset_subtype_rule_asset_subtype_id')
    expect(rendered).to have_field('policy_asset_subtype_rule_min_service_life_months')
    expect(rendered).to have_field('policy_asset_subtype_rule_replacement_cost')
    expect(rendered).to have_field('policy_asset_subtype_rule_cost_fy_year')
    expect(rendered).to have_field('policy_asset_subtype_rule_replace_with_new')
    # expect(rendered).to have_field('policy_asset_subtype_rule_replace_with_leased')
    expect(rendered).to have_field('policy_asset_subtype_rule_fuel_type_id')
    expect(rendered).to have_field('policy_asset_subtype_rule_min_service_life_miles')
    expect(rendered).to have_field('policy_asset_subtype_rule_min_used_purchase_service_life_months')
    # expect(rendered).to have_field('policy_asset_subtype_rule_lease_length_months')
    # expect(rendered).to have_field('policy_asset_subtype_rule_replace_asset_subtype_id')
    # expect(rendered).to have_field('policy_asset_subtype_rule_replace_fuel_type_id')
    expect(rendered).to have_field('policy_asset_subtype_rule_purchase_replacement_code')
    expect(rendered).to have_field('policy_asset_subtype_rule_lease_replacement_code')
    expect(rendered).to have_field('policy_asset_subtype_rule_purchase_expansion_code')
    expect(rendered).to have_field('policy_asset_subtype_rule_lease_expansion_code')
    expect(rendered).to have_field('policy_asset_subtype_rule_engineering_design_code')
    # expect(rendered).to have_field('policy_asset_subtype_rule_rehabilitation_service_month')
    # expect(rendered).to have_field('policy_asset_subtype_rule_rehabilitation_labor_cost')
    # expect(rendered).to have_field('policy_asset_subtype_rule_rehabilitation_parts_cost')
    # expect(rendered).to have_field('policy_asset_subtype_rule_extended_service_life_months')
    # expect(rendered).to have_field('policy_asset_subtype_rule_extended_service_life_miles')
    # expect(rendered).to have_field('policy_asset_subtype_rule_rehabilitation_code')
  end
  it 'not vehicles' do
    allow(controller).to receive(:current_user).and_return(create(:manager))
    test_policy = create(:policy)
    assign(:rule, PolicyAssetSubtypeRule.new(:policy => test_policy, :asset_subtype => AssetType.find_by(:class_name => 'TransitFacility').asset_subtypes.first))
    assign(:policy, test_policy)
    assign(:asset_type, AssetType.find_by(:class_name => 'TransitFacility'))
    assign(:valid_types, [])
    render

    expect(rendered).to have_field('policy_asset_subtype_rule_construction_code')
  end
end
