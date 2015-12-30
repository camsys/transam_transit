require 'rails_helper'

describe "assets/_transit_facility_fta.html.haml", :type => :view do

  class TestOrg < Organization
    def get_policy
      return Policy.where("`organization_id` = ?",self.id).order('created_at').last
    end
  end

  it 'fta info' do
    test_asset = create(:bus_shelter, :fta_funding_type_id => 1, :pcnt_capital_responsibility =>22, :fta_facility_type_id => 1)
    test_asset.fta_mode_types << FtaModeType.first
    test_asset.fta_service_types << FtaServiceType.first
    test_asset.save!
    assign(:asset, test_asset)
    render

    expect(rendered).to have_content(FtaFundingType.first.to_s)
    expect(rendered).to have_content('22%')
    expect(rendered).to have_content(FtaModeType.first.to_s)
    expect(rendered).to have_content(FtaServiceType.first.to_s)
    expect(rendered).to have_content(FtaFacilityType.first.to_s)
  end
end
