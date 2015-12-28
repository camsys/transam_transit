require 'rails_helper'

describe "asset_events/_mileage_update_event_form.html.haml", :type => :view do
  it 'fields' do
    assign(:asset, create(:buslike_asset))
    assign(:asset_event, MileageUpdateEvent.new)
    render

    expect(rendered).to have_field('asset_event_current_mileage')
    expect(rendered).to have_field('asset_event_event_date')
    expect(rendered).to have_field('asset_event_comments')
  end
end
