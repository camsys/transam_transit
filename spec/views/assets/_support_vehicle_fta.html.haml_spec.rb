require 'rails_helper'

describe "assets/_support_vehicle_fta.html.haml", :type => :view do
  it 'fta info' do
    test_asset = create(:tow_truck, :fta_funding_type_id => 1, :pcnt_capital_responsibility => 33, :fta_vehicle_type_id => 1, :fta_ownership_type_id => 1, :primary_fta_mode_type => FtaModeType.first)
    test_asset.secondary_fta_mode_types << FtaModeType.second
    assign(:asset, Asset.get_typed_asset(test_asset))
    render

    expect(rendered).to have_content(FtaFundingType.first.to_s)
    expect(rendered).to have_content('33%')
    expect(rendered).to have_content(FtaModeType.first.to_s)
    expect(rendered).to have_content(FtaModeType.second.to_s)
    expect(rendered).to have_content(FtaSupportVehicleType.find(2).to_s)
    expect(rendered).to have_content(FtaOwnershipType.first.code)
  end
end
