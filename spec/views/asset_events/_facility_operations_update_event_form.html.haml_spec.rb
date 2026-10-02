require 'rails_helper'

describe "asset_events/_facility_operations_update_event_form.html.haml", :type => :view do
  it 'fields' do
    organization = create(:organization)
    parent_policy = create(:parent_policy)
    create(:policy, organization: organization, parent: parent_policy)
    test_asset = create(:revenue_vehicle, organization: organization)
    assign(:asset, test_asset)
    assign(:asset_event, FacilityOperationsUpdateEvent.new(:transam_asset => test_asset))
    render

    expect(rendered).to have_field('asset_event_annual_affected_ridership')
    expect(rendered).to have_field('asset_event_annual_dollars_generated')
    expect(rendered).to have_field('asset_event_event_date')
    expect(rendered).to have_field('asset_event_comments')
  end
end
