require 'rails_helper'

describe "assets/_locomotive_configuration.html.haml", :type => :view do
  it 'info' do
    test_asset = create(:buslike_asset, :manufacturer => create(:manufacturer), :manufacturer_model => 'silverado', :manufacture_year => 2010, :fuel_type_id => 1, :vehicle_length => 40, :rebuild_year => 2020)
    assign(:asset, Asset.get_typed_asset(test_asset))
    render

    expect(rendered).to have_content(test_asset.manufacturer.name)
    expect(rendered).to have_content('silverado')
    expect(rendered).to have_content('2010')
    expect(rendered).to have_content('40')
    expect(rendered).to have_content('2020')
  end
end
