require 'rails_helper'

describe "assets/_vehicle_purchase.html.haml", :type => :view do
  it 'purchase info' do
    test_asset = create(:buslike_asset, :purchase_cost => 1234, :purchase_date => Date.new(2010,1,1), :warranty_date => Date.new(2010,2,1), :in_service_date => Date.new(2010,3,1), :vendor => create(:vendor), :expected_useful_miles => 44444, :title_number => 'abc123', :title_owner_organization_id => create(:organization).id)
    test_asset = Asset.get_typed_asset(test_asset)
    assign(:asset, test_asset)
    render

    expect(rendered).to have_content('$1,234')
    expect(rendered).to have_content('01/01/2010')
    expect(rendered).to have_content('02/01/2010')
    expect(rendered).to have_content('03/01/2010')
    expect(rendered).to have_content(test_asset.vendor.to_s)
    expect(rendered).to have_content('1 yrs')
    expect(rendered).to have_content('44,444')
    expect(rendered).to have_content(test_asset.title_number)
    expect(rendered).to have_content(test_asset.title_owner.name)
  end
end
