require 'rails_helper'

describe "asset_events/_operations_update_event_view.html.haml", :type => :view do
  it 'info' do
    test_asset = create(:buslike_asset)
    test_asset.asset_events.create!(attributes_for(:operations_update_event, :avg_cost_per_mile => 2.33, :avg_miles_per_gallon => 24.4, :annual_maintenance_cost => 4000, :annual_insurance_cost => 1000, :event_date => Date.new(2017,1,1), :comments => 'test comment 900'))
    assign(:asset_event, test_asset.asset_events.last)
    render

    expect(rendered).to have_content('$2.33')
    expect(rendered).to have_content('24.40')
    expect(rendered).to have_content('$4,000.00')
    expect(rendered).to have_content('$1,000.00')
    expect(rendered).to have_content('01/01/2017')
    expect(rendered).to have_content('test comment 900')
  end
end
