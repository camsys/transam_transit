require 'rails_helper'

describe "assets/_asset_location_details.html.haml", :type => :view do
  it 'info' do
    test_asset = create(:buslike_asset, :parent => create(:administration_building))
    assign(:asset, test_asset)
    render 'assets/asset_location_details', :asset => test_asset

    expect(rendered).to have_link(test_asset.parent.object_key)
  end
end
