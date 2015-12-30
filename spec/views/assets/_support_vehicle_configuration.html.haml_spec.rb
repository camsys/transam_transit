require 'rails_helper'

describe "assets/_support_vehicle_configuration.html.haml", :type => :view do
  it 'info' do
    test_asset = create(:buslike_asset, :manufacturer => create(:manufacturer), :manufacturer_model => 'silverado', :manufacture_year => 2010, :fuel_type_id => 1, :serial_number => 'abcdefgh1234567', :license_plate => 'PQRS987', :gross_vehicle_weight => 3333, :seating_capacity => 22)
    assign(:asset, Asset.get_typed_asset(test_asset))
    render

    expect(rendered).to have_content(test_asset.manufacturer.name)
    expect(rendered).to have_content('silverado')
    expect(rendered).to have_content('2010')
    expect(rendered).to have_content(FuelType.first.to_s)
    expect(rendered).to have_content('abcdefgh1234567')
    expect(rendered).to have_content('3,333')
    expect(rendered).to have_content('22')
    expect(rendered).to have_content('PQRS987')
  end
end
