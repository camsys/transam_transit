require 'rails_helper'

describe "asset_events/_facility_operations_update_event_view.html.haml", :type => :view do
  it 'info' do
    test_asset = create(:buslike_asset)
    test_asset.asset_events.create!(attributes_for(:facility_operations_update_event, :annual_affected_ridership => 123, :annual_dollars_generated => 4560, :event_date => Date.new(3017,1,1), :comments => 'test comment 900'))
    assign(:asset_event, test_asset.asset_events.last)
    render

    expect(rendered).to have_content(123)
    expect(rendered).to have_content('$4,560')
    expect(rendered).to have_content('01/01/3017')
    expect(rendered).to have_content('test comment 900')
  end
end
