require 'rails_helper'

describe "asset_events/_mileage_update_event_view.html.haml", :type => :view do
  it 'info' do
    test_asset = create(:buslike_asset)
    test_asset.asset_events.create!(attributes_for(:mileage_update_event, :current_mileage => 2222, :event_date => Date.new(2017,1,1), :comments => 'test comment 900'))
    assign(:asset_event, test_asset.asset_events.last)
    render

    expect(rendered).to have_content('2,222')
    expect(rendered).to have_content('01/01/2017')
    expect(rendered).to have_content('test comment 900')
  end
end
