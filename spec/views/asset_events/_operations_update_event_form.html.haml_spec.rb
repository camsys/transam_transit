require 'rails_helper'

describe "asset_events/_operations_update_event_form.html.haml", :type => :view do
  before { skip('UpdateEvent assumes transam_asset. Not yet testable.') }

  it 'fields' do
    test_asset = create(:buslike_asset)
    assign(:asset, test_asset)
    assign(:asset_event, OperationsUpdateEvent.new(:asset => test_asset))
    render

    expect(rendered).to have_field('asset_event_avg_cost_per_mile')
    expect(rendered).to have_field('asset_event_avg_miles_per_gallon')
    expect(rendered).to have_field('asset_event_annual_maintenance_cost')
    expect(rendered).to have_field('asset_event_annual_insurance_cost')
    expect(rendered).to have_field('asset_event_event_date')
    expect(rendered).to have_field('asset_event_comments')
  end
end
