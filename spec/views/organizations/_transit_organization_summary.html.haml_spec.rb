require 'rails_helper'

describe "organizations/_transit_organization_summary.html.haml", :type => :view do
  it 'info' do
    test_org = create(:organization, :subrecipient_number => 'abcde1234', :ntd_id_number => 'PQRS')
    assign(:org, test_org)
    render 'organizations/transit_organization_summary', :org => test_org

    expect(rendered).to have_content('abcde1234')
    expect(rendered).to have_content('PQRS')
  end
end
