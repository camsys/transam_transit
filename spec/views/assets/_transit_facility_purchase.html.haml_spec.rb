require 'rails_helper'

describe "assets/_transit_facility_purchase.html.haml", :type => :view do
  it 'purchase info' do
    test_asset = create(:bus_shelter, :purchase_cost => 1234, :purchase_date => Date.new(2010,1,1), :warranty_date => Date.new(2010,2,1), :in_service_date => Date.new(2010,3,1), :manufacturer => create(:manufacturer), :vendor => create(:vendor), :land_ownership_type_id => 1, :land_ownership_organization => create(:organization), :building_ownership_type_id => 2, :building_ownership_organization => create(:organization))
    assign(:asset, test_asset)
    render

    expect(rendered).to have_content('$1,234')
    expect(rendered).to have_content('01/01/2010')
    expect(rendered).to have_content('02/01/2010')
    expect(rendered).to have_content('03/01/2010')
    expect(rendered).to have_content(test_asset.manufacturer.to_s)
    expect(rendered).to have_content(test_asset.vendor.to_s)
    expect(rendered).to have_content('2 yrs')
    expect(rendered).to have_content(FtaOwnershipType.first.to_s)
    expect(rendered).to have_content(FtaOwnershipType.second.to_s)
    expect(rendered).to have_content(test_asset.land_ownership_organization.name)
    expect(rendered).to have_content(test_asset.building_ownership_organization.name)
  end
end
