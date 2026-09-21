require 'rails_helper'

describe "asset_events/_disposition_update_event_form.html.haml", :type => :view do
  it 'fields' do
    organization = create(:organization)
    parent_policy = create(:parent_policy)
    create(:policy, organization: organization, parent: parent_policy)
    # RevenueVehicle's class name contains 'Vehicle', which the partial's :16/:18/:26 checks
    # (@asset.class.to_s.include? 'Vehicle') need to render mileage_at_disposition below.
    test_asset = create(:revenue_vehicle, organization: organization)
    assign(:asset, test_asset)
    assign(:asset_event, DispositionUpdateEvent.new(:transam_asset => test_asset))
    render

    expect(rendered).to have_field('asset_event_event_date')
    expect(rendered).to have_field('asset_event_disposition_type_id')
    expect(rendered).to have_field('asset_event_sales_proceeds')
    expect(rendered).to have_field('asset_event_mileage_at_disposition')
    expect(rendered).to have_field('asset_event_comments')
  end
end
