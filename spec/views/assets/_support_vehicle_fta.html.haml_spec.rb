require 'rails_helper'

describe "assets/_support_vehicle_fta.html.haml", :type => :view do
  it 'fta info' do
    test_asset = create(:buslike_asset, :fta_funding_type_id => 1, :pcnt_capital_responsibility => 33, :fta_vehicle_type_id => 1, :fta_ownership_type_id => 1)
    assign(:asset, Asset.get_typed_asset(test_asset))
    render

    expect(rendered).to have_content(FtaFundingType.first.to_s)
    expect(rendered).to have_content(FtaVehicleType.find(1).to_s)
    expect(rendered).to have_content(FtaOwnershipType.first.code)
    expect(rendered).to have_content('33%')
  end
end
