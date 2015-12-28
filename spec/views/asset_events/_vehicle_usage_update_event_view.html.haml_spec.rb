require 'rails_helper'

describe "asset_events/_vehicle_usage_update_event_view.html.haml", :type => :view do
  it 'info' do
    test_asset = create(:buslike_asset)
    test_asset.asset_events.create!(attributes_for(:vehicle_usage_update_event, :pcnt_5311_routes => 33, :avg_daily_use_hours => 17, :avg_daily_use_miles => 222, :avg_daily_passenger_trips => 11, :event_date => Date.new(2017,1,1), :comments => 'test comment 900'))
    assign(:asset_event, test_asset.asset_events.last)
    render

    expect(rendered).to have_content('33%')
    expect(rendered).to have_content('17')
    expect(rendered).to have_content('222')
    expect(rendered).to have_content('11')
    expect(rendered).to have_content('01/01/2017')
    expect(rendered).to have_content('test comment 900')
  end
end
