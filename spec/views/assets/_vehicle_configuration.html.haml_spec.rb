require 'rails_helper'

describe "assets/_vehicle_configuration.html.haml", :type => :view do

  class TestOrg < Organization
    def get_policy
      return Policy.where("`organization_id` = ?",self.id).order('created_at').last
    end
  end

  it 'info' do
    test_asset = create(:buslike_asset, :manufacturer => create(:manufacturer), :manufacturer_model => 'silverado', :manufacture_year => 2010, :fuel_type_id => 1, :serial_number => 'abcdefgh1234567', :license_plate => 'PQRS987', :vehicle_length => 40, :gross_vehicle_weight => 3333, :seating_capacity => 22, :standing_capacity => 33, :wheelchair_capacity => 11, :rebuild_year => 2020, :vehicle_rebuild_type_id => 1)
    test_asset = Asset.get_typed_asset(test_asset)
    test_asset.vehicle_features << VehicleFeature.first
    test_asset.save!
    assign(:asset, test_asset)
    render

    expect(rendered).to have_content(test_asset.manufacturer.to_s)
    expect(rendered).to have_content('silverado')
    expect(rendered).to have_content('2010')
    expect(rendered).to have_content(FuelType.first.to_s)
    expect(rendered).to have_content('abcdefgh1234567')
    expect(rendered).to have_content('40')
    expect(rendered).to have_content('3,333')
    expect(rendered).to have_content('11')
    expect(rendered).to have_content('22')
    expect(rendered).to have_content('33')
    expect(rendered).to have_content('2020')
    expect(rendered).to have_content('PQRS987')
    expect(rendered).to have_content(VehicleRebuildType.first.to_s)
    expect(rendered).to have_content(VehicleFeature.first.to_s)
  end
end
