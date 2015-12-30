require 'rails_helper'

describe "assets/_rail_car_configuration.html.haml", :type => :view do
  it 'info' do
    test_asset = create(:buslike_asset, :manufacturer => create(:manufacturer), :manufacturer_model => 'silverado', :manufacture_year => 2010, :fuel_type_id => 1, :vehicle_length => 40, :rebuild_year => 2020, :seating_capacity => 33, :standing_capacity => 22, :wheelchair_capacity => 11)
    assign(:asset, Asset.get_typed_asset(test_asset))
    render

    expect(rendered).to have_content(test_asset.manufacturer.name)
    expect(rendered).to have_content('silverado')
    expect(rendered).to have_content('2010')
    expect(rendered).to have_content('40')
    expect(rendered).to have_content('2020')
    expect(rendered).to have_content('33')
    expect(rendered).to have_content('22')
    expect(rendered).to have_content('11')
    expect(rendered).to have_content(FuelType.first.to_s)
  end
end
