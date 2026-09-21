require 'rails_helper'

describe "asset_events/_operations_update_event_form.html.haml", :type => :view do
  it 'fields' do
    organization = create(:organization)
    parent_policy = create(:parent_policy)
    create(:policy, organization: organization, parent: parent_policy)
    test_asset = create(:revenue_vehicle, organization: organization)
    assign(:asset, test_asset)
    assign(:asset_event, OperationsUpdateEvent.new(:transam_asset => test_asset))
    render

    expect(rendered).to have_field('asset_event_avg_cost_per_mile')
    expect(rendered).to have_field('asset_event_avg_miles_per_gallon')
    expect(rendered).to have_field('asset_event_annual_maintenance_cost')
    expect(rendered).to have_field('asset_event_annual_insurance_cost')
    expect(rendered).to have_field('asset_event_event_date')
    expect(rendered).to have_field('asset_event_comments')
  end
end
