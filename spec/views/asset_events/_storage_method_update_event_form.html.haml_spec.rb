require 'rails_helper'

describe "asset_events/_storage_method_update_event_form.html.haml", :type => :view do
  it 'fields' do
    assign(:asset, create(:buslike_asset))
    assign(:asset_event, StorageMethodUpdateEvent.new)
    render

    expect(rendered).to have_field('asset_event_vehicle_storage_method_type_id')
    expect(rendered).to have_field('asset_event_event_date')
    expect(rendered).to have_field('asset_event_comments')
  end
end
