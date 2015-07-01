require 'rails_helper'

RSpec.describe AssetSearcher, :type => :model do
  let(:asset) { create(:bus, :organization_id => 1) }
  let(:searcher) { AssetSearcher.new(:organization_id => asset.organization_id) }
  let(:bus) { create(:bus) }

  #------------------------------------------------------------------------------
  #
  # Vehicle Simple Equality Searches
  #
  #------------------------------------------------------------------------------

  it 'should be able to search by fuel type' do
    asset.update!(:fuel_type_id => 1)
    searcher = AssetSearcher.new(:fuel_type_id => asset.fuel_type_id, :organization_id => asset.organization_id)
    searcher.respond_to?(:fuel_type_id)

    expect(searcher.data.count).to eq(Asset.where(fuel_type_id: asset.fuel_type_id).where(organization_id: asset.organization_id).count)
  end

  it 'should be able to search by storage method type' do
    asset.update!(:vehicle_storage_method_type_id => 1)
    searcher = AssetSearcher.new(:vehicle_storage_method_type_id => asset.vehicle_storage_method_type_id, :organization_id => asset.organization_id)

    expect(searcher.data.count).to eq(Asset.where(vehicle_storage_method_type_id: asset.vehicle_storage_method_type_id).where(organization_id: asset.organization_id).count)
  end

  # # it 'should be able to search by fta mode type' do
  # #   asset.update!(:fta_mode_type_id => 1)
  # #   searcher.fta_mode_type_id = asset.fta_mode_type_id

  # #   expect(searcher.data.count).to eq(Asset.joins("INNER JOIN assets_fta_mode_types").where("assets_fta_mode_types.asset_id = assets.id AND assets_fta_mode_types.fta_mode_type_id = ?",asset.fta_mode_type_id).where(organization_id: asset.organization_id))
  # # end

  # it 'should be able to search by fta bus mode type' do
  #   asset.update!(:fta_bus_mode_id => 1)
  #   searcher.fta_bus_mode_id = asset.fta_bus_mode_id

  #   expect(searcher.data.count).to eq(Asset.where(fta_bus_mode_id: asset.fta_bus_mode_id).where(organization_id: asset.organization_id).count)
  # end

  # it 'should be able to search by fta ownership type' do
  #   asset.update!(:fta_ownership_type_id => 1)
  #   searcher.fta_ownership_type_id = asset.fta_ownership_type_id

  #   expect(searcher.data.count).to eq(Asset.where(fta_ownership_type_id: asset.fta_ownership_type_id).where(organization_id: asset.organization_id).count)
  # end

  # it 'should be able to search by fta vehicle type' do
  #   asset.update!(:fta_vehicle_type_id => 1)
  #   searcher.fta_vehicle_type_id = asset.fta_vehicle_type_id

  #   expect(searcher.data.count).to eq(Asset.where(fta_vehicle_type_id: asset.fta_vehicle_type_id).where(organization_id: asset.organization_id).count)
  # end

  # it 'should be able to search by fta service type' do
  #   asset.update!(:fta_service_type_id => 1)
  #   searcher.fta_service_type_id = asset.fta_service_type_id

  #   expect(searcher.data.count).to eq(Asset.where(fta_service_type_id: asset.fta_service_type_id).where(organization_id: asset.organization_id).count)
  # end

  # # it 'should be able to search by usage_code type' do
  # #   asset.update!(:fta_mode_type_id => 1)
  # #   searcher.fta_mode_type_id = asset.fta_mode_type_id

  # #   expect(searcher.data.count).to eq(Asset.joins("INNER JOIN assets_usage_codes").where("assets_usage_codes.asset_id = assets.id AND assets_usage_codes.usage_code_id = ?",asset.vehicle_usage_code_id).where(organization_id: asset.organization_id))
  # # end

  # #------------------------------------------------------------------------------
  # #
  # # Vehicle Comparator Searches
  # #
  # #------------------------------------------------------------------------------

  # it 'should be able to search by vehicle length' do
  #   asset.update!(:vehicle_length => 10)

  #   searcher.vehicle_length = asset.vehicle_length
  #   searcher.vehicle_length_comparator = '0'
  #   expect(searcher.data.count).to eq(Asset.where(vehicle_length: asset.vehicle_length).where(organization_id: asset.organization_id).count)

  #   searcher.vehicle_length_comparator = '-1'
  #   expect(searcher.data.count).to eq(Asset.where('vehicle_length < ?',  asset.vehicle_length).where(organization_id: asset.organization_id).count)

  #   searcher.vehicle_length_comparator = '1'
  #   expect(searcher.data.count).to eq(Asset.where('vehicle_length > ?',  asset.vehicle_length).where(organization_id: asset.organization_id).count)
  # end

  # it 'should be able to search by seating capacity' do
  #   asset.update!(:seating_capacity => 10)

  #   searcher.seating_capacity = asset.seating_capacity
  #   searcher.seating_capacity_comparator = '0'
  #   expect(searcher.data.count).to eq(Asset.where(seating_capacity: asset.seating_capacity).where(organization_id: asset.organization_id).count)

  #   searcher.vehicle_length_comparator = '-1'
  #   expect(searcher.data.count).to eq(Asset.where('seating_capacity < ?',  asset.seating_capacity).where(organization_id: asset.organization_id).count)

  #   searcher.vehicle_length_comparator = '1'
  #   expect(searcher.data.count).to eq(Asset.where('seating_capacity > ?',  asset.seating_capacity).where(organization_id: asset.organization_id).count)
  # end

  # it 'should be able to search by standing capacity' do
  #   asset.update!(:standing_capacity => 10)

  #   searcher.standing_capacity = asset.standing_capacity
  #   searcher.standing_capacity_comparator = '0'
  #   expect(searcher.data.count).to eq(Asset.where(standing_capacity: asset.seating_capacity).where(organization_id: asset.organization_id).count)

  #   searcher.standing_capacity_comparator = '-1'
  #   expect(searcher.data.count).to eq(Asset.where('standing_capacity < ?',  asset.seating_capacity).where(organization_id: asset.organization_id).count)

  #   searcher.standing_capacity_comparator = '1'
  #   expect(searcher.data.count).to eq(Asset.where('standing_capacity > ?',  asset.seating_capacity).where(organization_id: asset.organization_id).count)
  # end

  # it 'should be able to search by wheelchair capacity' do
  #   asset.update!(:wheelchair_capacity => 10)

  #   searcher.wheelchair_capacity = asset.wheelchair_capacity
  #   searcher.wheelchair_capacity_comparator = '0'
  #   expect(searcher.data.count).to eq(Asset.where(wheelchair_capacity: asset.wheelchair_capacity).where(organization_id: asset.organization_id).count)

  #   searcher.wheelchair_capacity_comparator = '-1'
  #   expect(searcher.data.count).to eq(Asset.where('wheelchair_capacity < ?',  asset.seating_capacity).where(organization_id: asset.organization_id).count)

  #   searcher.wheelchair_capacity_comparator = '1'
  #   expect(searcher.data.count).to eq(Asset.where('wheelchair_capacity > ?',  asset.seating_capacity).where(organization_id: asset.organization_id).count)
  # end

  # it 'should be able to search by gross vehicle weight' do
  #   asset.update!(:gross_vehicle_weight => 10)

  #   searcher.gross_vehicle_weight = asset.gross_vehicle_weight
  #   searcher.gross_vehicle_weight_comparator = '0'
  #   expect(searcher.data.count).to eq(Asset.where(gross_vehicle_weight: asset.gross_vehicle_weight).where(organization_id: asset.organization_id).count)

  #   searcher.gross_vehicle_weight_comparator = '-1'
  #   expect(searcher.data.count).to eq(Asset.where('gross_vehicle_weight < ?',  asset.gross_vehicle_weight).where(organization_id: asset.organization_id).count)

  #   searcher.gross_vehicle_weight_comparator = '1'
  #   expect(searcher.data.count).to eq(Asset.where('gross_vehicle_weight > ?',  asset.gross_vehicle_weight).where(organization_id: asset.organization_id).count)
  # end

  # it 'should be able to search by rebuild year' do
  #   asset.update!(:rebuild_year => Date.today.year)

  #   searcher.rebuild_year = asset.rebuild_year
  #   searcher.rebuild_year_comparator = '0'
  #   expect(searcher.data.count).to eq(Asset.where(rebuild_year: asset.gross_vehicle_weight).where(organization_id: asset.organization_id).count)

  #   searcher.rebuild_year_comparator = '-1'
  #   expect(searcher.data.count).to eq(Asset.where('rebuild_year < ?',  asset.rebuild_year).where(organization_id: asset.organization_id).count)

  #   searcher.rebuild_year_comparator = '1'
  #   expect(searcher.data.count).to eq(Asset.where('rebuild_year > ?',  asset.rebuild_year).where(organization_id: asset.organization_id).count)
  # end

  # it 'should be able to search by current mileage' do
  #   asset.update!(:current_mileage => 10000)

  #   searcher.current_mileage = asset.current_mileage
  #   searcher.current_mileage_comparator = '0'
  #   expect(searcher.data.count).to eq(Asset.where(current_mileage: asset.current_mileage).where(organization_id: asset.organization_id).count)

  #   searcher.current_mileage_comparator = '-1'
  #   expect(searcher.data.count).to eq(Asset.where('current_mileage < ?',  asset.current_mileage).where(organization_id: asset.organization_id).count)

  #   searcher.current_mileage_comparator = '1'
  #   expect(searcher.data.count).to eq(Asset.where('rebuild_year > ?',  asset.current_mileage).where(organization_id: asset.organization_id).count)
  # end

  # #------------------------------------------------------------------------------
  # #
  # # Vehicle Checkbox Searches
  # #
  # #------------------------------------------------------------------------------
  # it 'should be able to search by fta contingency fleet' do
  #   asset.update!(:fta_contingency_fleet => true)
  #   searcher.fta_service_type_id = asset.fta_contingency_fleet

  #   expect(searcher.data.count).to eq(Asset.where(fta_service_type_id: asset.fta_contingency_fleet).where(organization_id: asset.organization_id).count)
  # end

  # it 'should be able to search by ada accessibility' do
  #   asset.update!(:ada_accessible_ramp => true, :ada_accessible_lift => false)
  #   searcher.ada_accessible_ramp = asset.ada_accessible_ramp

  #   expect(searcher.data.count).to eq(Asset.where('ada_accessible_ramp = 1 OR ada_accessible_lift = 1')
  #     .where(organization_id: asset.organization_id).count)
  # end

  # #------------------------------------------------------------------------------
  # #
  # # Facility Equality Searches
  # #
  # #------------------------------------------------------------------------------
  # # it 'should be able to search by facility feature codes' do

  # # end

  # it 'should be able to search by facility capacity type' do
  #   asset.update!(:facility_capacity_type_id => 1)
  #   searcher.facility_capacity_type_id = asset.facility_capacity_type_id

  #   expect(searcher.data.count).to eq(Asset.where(facility_capacity_type_id: asset.facility_capacity_type_id).count)
  # end

  # # it 'should be able to search by NTD Modes' do

  # # end

  # it 'should be able to search by FTA Land Ownership Type' do
  #   asset.update!(:land_ownership_type_id => 1)
  #   searcher.fta_land_ownership_type_id = asset.land_ownership_type_id

  #   expect(searcher.data.count).to eq(Asset.where(fta_land_ownership_type_id: asset.land_ownership_type_id).count)
  # end

  # it 'should be able to search by FTA Building Ownership Type' do
  #   asset.update!(:building_ownership_type_id => 1)
  #   searcher.fta_building_ownership_type_id = asset.building_ownership_type_id

  #   expect(searcher.data.count).to eq(Asset.where(building_ownership_type_id: asset.building_ownership_type_id).count)
  # end

  # it 'should be able to search by FTA Building Ownership Type' do
  #   asset.update!(:fta_building_ownership_type_id => 1)
  #   searcher.fta_building_ownership_type_id = asset.fta_building_ownership_type_id

  #   expect(searcher.data.count).to eq(Asset.where(building_ownership_type_id: asset.fta_building_ownership_type_id).count)
  # end

  # it 'should be able to search by LEED Certification Type' do
  #   asset.update!(:leed_certification_type_id => 1)
  #   searcher.leed_certification_type_id = asset.leed_certification_type_id

  #   expect(searcher.data.count).to eq(Asset.where(leed_certification_type_id: asset.leed_certification_type_id).count)
  # end

  # #------------------------------------------------------------------------------
  # #
  # # Facility Comparator Searches
  # #
  # #------------------------------------------------------------------------------

  # it 'should be able to search by facility size' do
  #   asset.update!(:facility_size => 10000)

  #   searcher.facility_size = asset.facility_size
  #   searcher.facility_size_comparator = '0'
  #   expect(searcher.data.count).to eq(Asset.where(facility_size: asset.facility_size).where(organization_id: asset.organization_id).count)

  #   searcher.current_mileage_comparator = '-1'
  #   expect(searcher.data.count).to eq(Asset.where('facility_size < ?',  asset.facility_size).where(organization_id: asset.organization_id).count)

  #   searcher.current_mileage_comparator = '1'
  #   expect(searcher.data.count).to eq(Asset.where('facility_size > ?',  asset.facility_size).where(organization_id: asset.organization_id).count)
  # end

  # it 'should be able to search by lot size' do
  #   asset.update!(:lot_size => 10000)

  #   searcher.lot_size = asset.lot_size
  #   searcher.lot_size_comparator = '0'
  #   expect(searcher.data.count).to eq(Asset.where(lot_size: asset.lot_size).where(organization_id: asset.organization_id).count)

  #   searcher.lot_size_comparator = '-1'
  #   expect(searcher.data.count).to eq(Asset.where('lot_size < ?',  asset.lot_size).where(organization_id: asset.organization_id).count)

  #   searcher.lot_size_comparator = '1'
  #   expect(searcher.data.count).to eq(Asset.where('lot_size > ?',  asset.lot_size).where(organization_id: asset.organization_id).count)
  # end

  # it 'should be able to search by Percent Operational' do
  #   asset.update!(:pcnt_operational => 90)

  #   searcher.pcnt_operational = asset.pcnt_operational
  #   searcher.pcnt_operational_comparator = '0'
  #   expect(searcher.data.count).to eq(Asset.where(pcnt_operational: asset.pcnt_operational).where(organization_id: asset.organization_id).count)

  #   searcher.pcnt_operational_comparator = '-1'
  #   expect(searcher.data.count).to eq(Asset.where('pcnt_operational < ?',  asset.pcnt_operational).where(organization_id: asset.organization_id).count)

  #   searcher.pcnt_operational_comparator = '1'
  #   expect(searcher.data.count).to eq(Asset.where('pcnt_operational > ?',  asset.pcnt_operational).where(organization_id: asset.organization_id).count)
  # end

  # it 'should be able to search by number of floors' do
  #   asset.update!(:num_floors => 4)

  #   searcher.num_floors = asset.num_floors
  #   searcher.num_floors_comparator = '0'
  #   expect(searcher.data.count).to eq(Asset.where(num_floors: asset.num_floors).where(organization_id: asset.organization_id).count)

  #   searcher.num_floors_comparator = '-1'
  #   expect(searcher.data.count).to eq(Asset.where('num_floors < ?',  asset.num_floors).where(organization_id: asset.organization_id).count)

  #   searcher.num_floors_comparator = '1'
  #   expect(searcher.data.count).to eq(Asset.where('num_floors > ?',  asset.num_floors).where(organization_id: asset.organization_id).count)
  # end

  # it 'should be able to search by number of elevators' do
  #   asset.update!(:num_elevators => 4)

  #   searcher.num_elevators = asset.num_elevators
  #   searcher.num_elevators_comparator = '0'
  #   expect(searcher.data.count).to eq(Asset.where(num_elevators: asset.num_elevators).where(organization_id: asset.organization_id).count)

  #   searcher.num_elevators_comparator = '-1'
  #   expect(searcher.data.count).to eq(Asset.where('num_elevators < ?',  asset.num_elevators).where(organization_id: asset.organization_id).count)

  #   searcher.num_elevators_comparator = '1'
  #   expect(searcher.data.count).to eq(Asset.where('num_elevators > ?',  asset.num_elevators).where(organization_id: asset.organization_id).count)
  # end

  # it 'should be able to search by number of escalators' do
  #   asset.update!(:num_escalators => 4)

  #   searcher.num_escalators = asset.num_escalators
  #   searcher.num_escalators_comparator = '0'
  #   expect(searcher.data.count).to eq(Asset.where(num_escalators: asset.num_escalators).where(organization_id: asset.organization_id).count)

  #   searcher.num_escalators_comparator = '-1'
  #   expect(searcher.data.count).to eq(Asset.where('num_escalators < ?',  asset.num_escalators).where(organization_id: asset.organization_id).count)

  #   searcher.num_escalators_comparator = '1'
  #   expect(searcher.data.count).to eq(Asset.where('num_escalators > ?',  asset.num_escalators).where(organization_id: asset.organization_id).count)
  # end

  # it 'should be able to search by number of structures' do
  #   asset.update!(:num_structures => 4)

  #   searcher.num_structures = asset.num_structures
  #   searcher.num_structures_comparator = '0'
  #   expect(searcher.data.count).to eq(Asset.where(num_structures: asset.num_structures).where(organization_id: asset.organization_id).count)

  #   searcher.num_structures_comparator = '-1'
  #   expect(searcher.data.count).to eq(Asset.where('num_structures < ?',  asset.num_structures).where(organization_id: asset.organization_id).count)

  #   searcher.num_structures_comparator = '1'
  #   expect(searcher.data.count).to eq(Asset.where('num_structures > ?',  asset.num_structures).where(organization_id: asset.organization_id).count)
  # end

  # it 'should be able to search by number of private parking spaces' do
  #   asset.update!(:num_parking_spaces_private => 4)

  #   searcher.num_parking_spaces_private = asset.num_parking_spaces_private
  #   searcher.num_parking_spaces_private_comparator = '0'
  #   expect(searcher.data.count).to eq(Asset.where(num_parking_spaces_private: asset.num_parking_spaces_private).where(organization_id: asset.organization_id).count)

  #   searcher.num_parking_spaces_private_comparator = '-1'
  #   expect(searcher.data.count).to eq(Asset.where('num_parking_spaces_private < ?',  asset.num_parking_spaces_private).where(organization_id: asset.organization_id).count)

  #   searcher.num_parking_spaces_private_comparator = '1'
  #   expect(searcher.data.count).to eq(Asset.where('num_parking_spaces_private > ?',  asset.num_parking_spaces_private).where(organization_id: asset.organization_id).count)
  # end

  # it 'should be able to search by number of public parking spaces' do
  #   asset.update!(:num_parking_spaces_public => 4)

  #   searcher.num_parking_spaces_public = asset.num_parking_spaces_public
  #   searcher.num_parking_spaces_public_comparator = '0'
  #   expect(searcher.data.count).to eq(Asset.where(num_parking_spaces_public: asset.num_parking_spaces_public).where(organization_id: asset.organization_id).count)

  #   searcher.num_parking_spaces_public_comparator = '-1'
  #   expect(searcher.data.count).to eq(Asset.where('num_parking_spaces_public < ?',  asset.num_parking_spaces_public).where(organization_id: asset.organization_id).count)

  #   searcher.num_parking_spaces_public_comparator = '1'
  #   expect(searcher.data.count).to eq(Asset.where('num_parking_spaces_public > ?',  asset.num_parking_spaces_public).where(organization_id: asset.organization_id).count)
  # end

end
