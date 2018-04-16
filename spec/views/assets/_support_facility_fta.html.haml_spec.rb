require 'rails_helper'

describe "assets/_support_facility_fta.html.haml", :type => :view do

  it 'fta info' do
    test_asset = create(:administration_building, :fta_funding_type_id => 1, :pcnt_capital_responsibility =>22, :fta_facility_type_id => FtaFacilityType.first.id, :facility_capacity_type_id => 1, :primary_fta_mode_type => FtaModeType.first, :fta_private_mode_type => FtaPrivateModeType.first)
    test_asset.secondary_fta_mode_types << FtaModeType.second
    test_asset.save!
    assign(:asset, test_asset)
    render

    expect(rendered).to have_content(FtaFundingType.first.to_s)
    expect(rendered).to have_content('22%')
    expect(rendered).to have_content(FtaModeType.first.to_s)
    expect(rendered).to have_content(FtaModeType.second.to_s)
    expect(rendered).to have_content(FtaPrivateModeType.first.to_s)
    expect(rendered).to have_content(FtaFacilityType.first.to_s)
    expect(rendered).to have_content(FacilityCapacityType.first.to_s)
  end
end
