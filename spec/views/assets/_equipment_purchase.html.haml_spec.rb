require 'rails_helper'

describe "assets/_equipment_purchase.html.haml", :type => :view do
  it 'purchase info' do
    test_asset = create(:equipment_asset, :purchase_cost => 1234, :purchase_date => Date.new(2010,1,1), :warranty_date => Date.new(2010,2,1), :in_service_date => Date.new(2010,3,1), :vendor => create(:vendor), :fta_funding_type_id => 1)
    assign(:asset, test_asset)
    render

    expect(rendered).to have_content('$1,234')
    expect(rendered).to have_content('01/01/2010')
    expect(rendered).to have_content('02/01/2010')
    expect(rendered).to have_content('03/01/2010')
    expect(rendered).to have_content(test_asset.vendor.to_s)
    expect(rendered).to have_content(FtaFundingType.first.to_s)
    expect(rendered).to have_content(test_asset.expected_useful_life)

  end
end
