require 'rails_helper'

describe "organizations/_services.html.haml", :type => :view do
  it 'info' do
    test_org = create(:transit_operator, :fta_agency_type_id => 1, :fta_service_area_type_id => 1)
    test_org = Organization.get_typed_organization(test_org)
    test_org.fta_mode_types << FtaModeType.first
    test_dist = create(:district)
    test_org.districts << test_dist
    test_org.service_provider_types << ServiceProviderType.first
    assign(:org, test_org)
    render

    expect(rendered).to have_content(test_org.fta_agency_type.to_s)
    expect(rendered).to have_content(FtaModeType.first.to_s)
    expect(rendered).to have_content(test_dist.to_s)
    expect(rendered).to have_content(ServiceProviderType.first.to_s)
  end
end
