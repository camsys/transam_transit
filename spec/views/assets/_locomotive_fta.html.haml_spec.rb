require 'rails_helper'

describe "assets/_locomotive_fta.html.haml", :type => :view do

  it 'fta info' do
    test_asset = create(:buslike_asset, :fta_funding_type_id => 1, :fta_vehicle_type_id => 1, :fta_ownership_type_id => 1)
    test_asset = Asset.get_typed_asset(test_asset)
    test_asset.fta_mode_types << FtaModeType.first
    test_asset.fta_service_types << FtaServiceType.first
    test_asset.save!
    assign(:asset, test_asset)
    render

    expect(rendered).to have_content(FtaFundingType.first.to_s)
    expect(rendered).to have_content(FtaVehicleType.find(1).to_s)
    expect(rendered).to have_content(FtaModeType.first.to_s)
    expect(rendered).to have_content(FtaServiceType.first.to_s)
    expect(rendered).to have_content(FtaOwnershipType.first.code)
  end
end
