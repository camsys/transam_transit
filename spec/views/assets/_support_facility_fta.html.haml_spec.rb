require 'rails_helper'

describe "assets/_support_facility_fta.html.haml", :type => :view do

  it 'fta info' do
    test_asset = create(:administration_building, :fta_funding_type_id => 1, :pcnt_capital_responsibility =>22, :fta_facility_type_id => 1, :facility_capacity_type_id => 1)
    test_asset.fta_mode_types << FtaModeType.first
    test_asset.save!
    assign(:asset, test_asset)
    render

    expect(rendered).to have_content(FtaFundingType.first.to_s)
    expect(rendered).to have_content('22%')
    expect(rendered).to have_content(FtaModeType.first.to_s)
    expect(rendered).to have_content(FtaFacilityType.first.to_s)
    expect(rendered).to have_content(FacilityCapacityType.first.to_s)
  end
end
