require 'rails_helper'

describe "asset_events/_usage_codes_update_event_form.html.haml", :type => :view do
  it 'fields' do
    organization = create(:organization)
    parent_policy = create(:parent_policy)
    create(:policy, organization: organization, parent: parent_policy)
    test_asset = create(:revenue_vehicle, organization: organization)
    assign(:asset, test_asset)
    assign(:asset_event, UsageCodesUpdateEvent.new(:transam_asset => test_asset))
    render

    expect(rendered).to have_field('asset_event_vehicle_usage_code_ids_1')
    expect(rendered).to have_field('asset_event_event_date')
    expect(rendered).to have_field('asset_event_comments')
  end
end
