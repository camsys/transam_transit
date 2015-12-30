require 'rails_helper'

describe "organizations/_governance.html.haml", :type => :view do
  it 'info' do
    test_ntd_contact = create(:admin)
    test_ntd_contact.add_role :ntd_contact
    test_org = create(:organization, :governing_body => 'test_governing_body', :governing_body_type_id => 1)
    test_org = Organization.get_typed_organization(test_org)
    assign(:org, test_org)
    render

    expect(rendered).to have_content(test_org.governing_body_type.to_s)
    expect(rendered).to have_content(test_org.governing_body)
    expect(rendered).to have_content('Not Set')
    expect(rendered).to have_content(test_org.ntd_contact)
  end
end
