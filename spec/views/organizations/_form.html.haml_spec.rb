require 'rails_helper'

describe "organizations/_form.html.haml", :type => :view do
  it 'fields' do
    Customer.create!(name: 'Test Customer', license_type_id: 1,active: true)
    create(:organization)
    assign(:org, TransitOperator.new)
    render

    expect(rendered).to have_field('organization_name')
    expect(rendered).to have_field('organization_short_name')
    expect(rendered).to have_field('organization_external_id')
    expect(rendered).to have_field('organization_governing_body_type_id')
    expect(rendered).to have_field('organization_governing_body')
    expect(rendered).to have_field('organization_indian_tribe')
    expect(rendered).to have_field('organization_subrecipient_number')
    expect(rendered).to have_field('organization_ntd_id_number')
    expect(rendered).to have_field('organization_fta_agency_type_id')
    expect(rendered).to have_field('organization_phone')
    expect(rendered).to have_field('organization_fax')
    expect(rendered).to have_field('organization_url')
    expect(rendered).to have_field('organization_address1')
    expect(rendered).to have_field('organization_address2')
    expect(rendered).to have_field('organization_city')
    expect(rendered).to have_field('organization_state')
    expect(rendered).to have_field('organization_zip')
    expect(rendered).to have_field('organization_fta_mode_type_ids_1')
    expect(rendered).to have_field('organization_fta_service_area_type_id')
    expect(rendered).to have_field('organization_district_ids')
    expect(rendered).to have_field('organization_service_provider_type_ids')
  end
end
