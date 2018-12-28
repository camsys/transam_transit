require 'rails_helper'

describe "asset_events/_vehicle_usage_update_event_form.html.haml", :type => :view do
  before { skip('UpdateEvent assumes transam_asset. Not yet testable.') }

  it 'fields' do
    test_asset = create(:buslike_asset)
    assign(:asset, test_asset)
    assign(:asset_event, VehicleUsageUpdateEvent.new(:asset => test_asset))
    render

    expect(rendered).to have_field('asset_event_pcnt_5311_routes')
    expect(rendered).to have_field('asset_event_avg_daily_use_hours')
    expect(rendered).to have_field('asset_event_avg_daily_use_miles')
    expect(rendered).to have_field('asset_event_avg_daily_passenger_trips')
    expect(rendered).to have_field('asset_event_event_date')
    expect(rendered).to have_field('asset_event_comments')
  end
end
