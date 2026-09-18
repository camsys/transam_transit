require 'rails_helper'

describe "asset_events/_usage_codes_update_event_view.html.haml", :type => :view do
  it 'info' do
    organization = create(:organization)
    parent_policy = create(:parent_policy)
    create(:policy, organization: organization, parent: parent_policy)
    test_asset = create(:service_vehicle, organization: organization)
    test_asset.usage_codes_updates.create!(attributes_for(:usage_codes_update_event, :event_date => Date.new(3017,1,1), :comments => 'test comment 900').merge(:vehicle_usage_codes => [VehicleUsageCode.first]))
    test_event = AssetEvent.as_typed_event(test_asset.asset_events.last)
    assign(:asset_event, test_event)
    render

    expect(rendered).to have_content(VehicleUsageCode.first.to_s)
    expect(rendered).to have_content('01/01/3017')
    expect(rendered).to have_content('test comment 900')
  end
end
