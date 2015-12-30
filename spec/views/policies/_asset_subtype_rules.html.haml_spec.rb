require 'rails_helper'

describe "policies/_asset_subtype_rules.html.haml", :type => :view do

  it 'list rules' do
    allow(controller).to receive(:current_ability).and_return(Ability.new(create(:admin)))
    test_policy = create(:policy)
    test_rule = create(:policy_asset_subtype_rule, :policy => test_policy)
    assign(:policy, test_policy)
    render 'policies/asset_subtype_rules', :asset_type => AssetType.first, :rules => [test_rule], :policy => test_policy

    expect(rendered).to have_content(test_rule.asset_subtype.to_s)
    expect(rendered).to have_content(test_rule.min_service_life_months)
    expect(rendered).to have_content('500,000')
    expect(rendered).to have_xpath('//a[@title="Alter rule..."]')
    expect(rendered).to have_xpath('//a[@title="Copy rule..."]')
  end
  
  it 'not default rule' do
    allow(controller).to receive(:current_ability).and_return(Ability.new(create(:admin)))
    test_policy = create(:policy)
    test_rule = create(:policy_asset_subtype_rule, :policy => test_policy, :default_rule => false)
    assign(:policy, test_policy)
    render 'policies/asset_subtype_rules', :asset_type => AssetType.first, :rules => [test_rule], :policy => test_policy

    expect(rendered).to have_xpath('//a[@title="Remove this rule..."]')
  end
end
