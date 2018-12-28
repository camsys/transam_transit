require 'rails_helper'
require_relative '../../app/searches/asset_searcher.rb'

RSpec.describe AssetSearcher, :type => :model do
  before { skip('AssetSearcher not refactored for TransamAsset.') }

  let(:asset) { create(:bus) }

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

  it 'should be able to search by fta bus mode type' do
    asset.update!(:fta_bus_mode_type_id => 1)
    searcher = AssetSearcher.new(:fta_bus_mode_type_id  => asset.fta_bus_mode_type_id, :organization_id => asset.organization_id)

    expect(searcher.data.count).to eq(Asset.where(fta_bus_mode_type_id: asset.fta_bus_mode_type_id).where(organization_id: asset.organization_id).count)
  end

  it 'should be able to search by fta ownership type' do
    asset.update!(:fta_ownership_type_id => 1)
    searcher = AssetSearcher.new(:fta_ownership_type_id => asset.fta_ownership_type_id , :organization_id => asset.organization_id)

    expect(searcher.data.count).to eq(Asset.where(fta_ownership_type_id: asset.fta_ownership_type_id).where(organization_id: asset.organization_id).count)
  end

  it 'should be able to search by fta vehicle type' do
    asset.update!(:fta_vehicle_type_id => 1)
    searcher = AssetSearcher.new(:fta_vehicle_type_id => asset.fta_vehicle_type_id , :organization_id => asset.organization_id)

    expect(searcher.data.count).to eq(Asset.where(fta_vehicle_type_id: asset.fta_vehicle_type_id).where(organization_id: asset.organization_id).count)
  end

  # #------------------------------------------------------------------------------
  # #
  # # Vehicle Comparator Searches
  # #
  # #------------------------------------------------------------------------------

  it 'should be able to search by vehicle length' do
    asset.update!(:vehicle_length => 10)

    searcher = AssetSearcher.new(:vehicle_length => asset.vehicle_length , :vehicle_length_comparator => '0', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where(vehicle_length: asset.vehicle_length).where(organization_id: asset.organization_id).count)

    lesser = AssetSearcher.new(:vehicle_length => asset.vehicle_length , :vehicle_length_comparator => '-1', :organization_id => asset.organization_id)
    expect(lesser.data.count).to eq(Asset.where('vehicle_length < ?',  asset.vehicle_length).where(organization_id: asset.organization_id).count)

    greater = AssetSearcher.new(:vehicle_length => asset.vehicle_length , :vehicle_length_comparator => '1', :organization_id => asset.organization_id)
    expect(greater.data.count).to eq(Asset.where('vehicle_length > ?',  asset.vehicle_length).where(organization_id: asset.organization_id).count)
  end

  it 'should be able to search by seating capacity' do
    asset.update!(:seating_capacity => 10)

    searcher = AssetSearcher.new(:seating_capacity => asset.seating_capacity , :seating_capacity_comparator => '0', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where(seating_capacity: asset.seating_capacity).where(organization_id: asset.organization_id).count)

    searcher = AssetSearcher.new(:seating_capacity => asset.seating_capacity , :seating_capacity_comparator => '-1', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where('seating_capacity < ?',  asset.seating_capacity).where(organization_id: asset.organization_id).count)

    searcher = AssetSearcher.new(:seating_capacity => asset.seating_capacity , :seating_capacity_comparator => '1', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where('seating_capacity > ?',  asset.seating_capacity).where(organization_id: asset.organization_id).count)
  end

  it 'should be able to search by standing capacity' do
    asset.update!(:standing_capacity => 10)

    searcher = AssetSearcher.new(:standing_capacity => asset.standing_capacity , :standing_capacity_comparator => '0', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where(standing_capacity: asset.standing_capacity).where(organization_id: asset.organization_id).count)

    searcher = AssetSearcher.new(:standing_capacity => asset.standing_capacity , :standing_capacity_comparator => '-1', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where('standing_capacity < ?',  asset.standing_capacity).where(organization_id: asset.organization_id).count)

    searcher = AssetSearcher.new(:standing_capacity => asset.standing_capacity , :standing_capacity_comparator => '1', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where('standing_capacity > ?',  asset.standing_capacity).where(organization_id: asset.organization_id).count)
  end

  it 'should be able to search by wheelchair capacity' do
    asset.update!(:wheelchair_capacity => 10)

    searcher = AssetSearcher.new(:wheelchair_capacity => asset.wheelchair_capacity , :wheelchair_capacity_comparator => '0', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where(wheelchair_capacity: asset.wheelchair_capacity).where(organization_id: asset.organization_id).count)

    searcher = AssetSearcher.new(:wheelchair_capacity => asset.wheelchair_capacity , :wheelchair_capacity_comparator => '-1', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where('wheelchair_capacity < ?',  asset.wheelchair_capacity).where(organization_id: asset.organization_id).count)

    searcher = AssetSearcher.new(:wheelchair_capacity => asset.wheelchair_capacity , :wheelchair_capacity_comparator => '1', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where('wheelchair_capacity > ?',  asset.wheelchair_capacity).where(organization_id: asset.organization_id).count)
  end

  it 'should be able to search by gross vehicle weight' do
    asset.update!(:gross_vehicle_weight => 10)

    searcher = AssetSearcher.new(:gross_vehicle_weight => asset.gross_vehicle_weight , :gross_vehicle_weight_comparator => '0', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where(gross_vehicle_weight: asset.gross_vehicle_weight).where(organization_id: asset.organization_id).count)

    searcher = AssetSearcher.new(:gross_vehicle_weight => asset.gross_vehicle_weight , :gross_vehicle_weight_comparator => '-1', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where('gross_vehicle_weight < ?',  asset.gross_vehicle_weight).where(organization_id: asset.organization_id).count)

    searcher = AssetSearcher.new(:gross_vehicle_weight => asset.gross_vehicle_weight , :gross_vehicle_weight_comparator => '1', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where('gross_vehicle_weight > ?',  asset.gross_vehicle_weight).where(organization_id: asset.organization_id).count)
  end

  it 'should be able to search by rebuild year' do
    asset.update!(:rebuild_year => Date.today.year)

    searcher = AssetSearcher.new(:rebuild_year => asset.rebuild_year , :rebuild_year_comparator => '0', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where(rebuild_year: asset.rebuild_year).where(organization_id: asset.organization_id).count)

    searcher = AssetSearcher.new(:rebuild_year => asset.rebuild_year , :rebuild_year_comparator => '-1', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where('rebuild_year < ?',  asset.rebuild_year).where(organization_id: asset.organization_id).count)

    searcher = AssetSearcher.new(:rebuild_year => asset.rebuild_year , :rebuild_year_comparator => '1', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where('rebuild_year > ?',  asset.rebuild_year).where(organization_id: asset.organization_id).count)
  end

  it 'should be able to search by current mileage' do
    event = create(:mileage_update_event)

    searcher = AssetSearcher.new(:current_mileage => event.current_mileage , :current_mileage_comparator => '0', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.joins(:asset_events).where(asset_events: { current_mileage: event.current_mileage} ).where(organization_id: asset.organization_id).count)

    searcher = AssetSearcher.new(:current_mileage => event.current_mileage , :current_mileage_comparator => '-1', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.joins(:asset_events).where('asset_events.current_mileage < ?',  event.current_mileage).where(organization_id: asset.organization_id).count)

    searcher = AssetSearcher.new(:current_mileage => event.current_mileage , :current_mileage_comparator => '1', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.joins(:asset_events).where('asset_events.current_mileage > ?',  event.current_mileage).where(organization_id: asset.organization_id).count)
  end

  # #------------------------------------------------------------------------------
  # #
  # # Vehicle Checkbox Searches
  # #
  # #------------------------------------------------------------------------------
  it 'should be able to search by fta emergency contingency fleet' do
    asset.update!(:fta_emergency_contingency_fleet => true)
    searcher = AssetSearcher.new(:fta_emergency_contingency_fleet => '1', :organization_id => asset.organization_id)

    expect(searcher.data.count).to eq(Asset.where(fta_emergency_contingency_fleet: asset.fta_emergency_contingency_fleet).where(organization_id: asset.organization_id).count)
  end

  it 'should be able to search by ada accessibility' do
    asset.update!(:ada_accessible_ramp => true, :ada_accessible_lift => false)
    searcher = AssetSearcher.new(:ada_accessible_ramp => '1', :ada_accessible_lift => '0',:organization_id => asset.organization_id)

    expect(searcher.data.count).to eq(Asset.where('ada_accessible_ramp = 1 OR ada_accessible_lift = 1')
      .where(organization_id: asset.organization_id).count)
  end

  # #------------------------------------------------------------------------------
  # #
  # # Facility Equality Searches
  # #
  # #------------------------------------------------------------------------------

  it 'should be able to search by facility capacity type' do
    asset = create(:bus_shelter, :facility_capacity_type_id => 1)
    searcher = AssetSearcher.new(:facility_capacity_type_id => asset.facility_capacity_type_id,:organization_id => asset.organization_id)

    expect(searcher.data.count).to eq(Asset.where(facility_capacity_type_id: asset.facility_capacity_type_id).count)
  end

  # # it 'should be able to search by NTD Modes' do

  # # end

  it 'should be able to search by FTA Land Ownership Type' do
    asset = create(:bus_shelter, :land_ownership_type_id => 1)
    searcher = AssetSearcher.new(:land_ownership_type_id => asset.land_ownership_type_id, :organization_id => asset.organization_id)

    expect(searcher.data.count).to eq(Asset.where(land_ownership_type_id: asset.land_ownership_type_id).count)
  end

  it 'should be able to search by FTA Building Ownership Type' do
    asset = create(:bus_shelter, :building_ownership_type_id => 1)
    searcher = AssetSearcher.new(:building_ownership_type_id => asset.building_ownership_type_id, :organization_id => asset.organization_id)

    expect(searcher.data.count).to eq(Asset.where(building_ownership_type_id: asset.building_ownership_type_id).count)
  end


  it 'should be able to search by LEED Certification Type' do
    asset = create(:bus_shelter, :leed_certification_type_id => 1)
    searcher = AssetSearcher.new(:leed_certification_type_id => asset.leed_certification_type_id, :organization_id => asset.organization_id)

    expect(searcher.data.count).to eq(Asset.where(leed_certification_type_id: asset.leed_certification_type_id).count)
  end

  # #------------------------------------------------------------------------------
  # #
  # # Facility Comparator Searches
  # #
  # #------------------------------------------------------------------------------

  it 'should be able to search by facility size' do
    asset = create(:bus_shelter, :facility_size => 10000)

    searcher = AssetSearcher.new(:facility_size => asset.facility_size , :facility_size_comparator => '0', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where(facility_size: asset.facility_size).where(organization_id: asset.organization_id).count)

    searcher = AssetSearcher.new(:facility_size => asset.facility_size , :facility_size_comparator => '-1', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where('facility_size < ?',  asset.facility_size).where(organization_id: asset.organization_id).count)

    searcher = AssetSearcher.new(:facility_size => asset.facility_size , :facility_size_comparator => '1', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where('facility_size > ?',  asset.facility_size).where(organization_id: asset.organization_id).count)
  end

  it 'should be able to search by lot size' do
    asset = create(:bus_shelter, :lot_size => 10000)

    searcher = AssetSearcher.new(:lot_size => asset.lot_size , :lot_size_comparator => '0', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where(lot_size: asset.lot_size).where(organization_id: asset.organization_id).count)

    searcher = AssetSearcher.new(:lot_size => asset.lot_size , :lot_size_comparator => '-1', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where('lot_size < ?',  asset.lot_size).where(organization_id: asset.organization_id).count)

    searcher = AssetSearcher.new(:lot_size => asset.lot_size , :lot_size_comparator => '1', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where('lot_size > ?',  asset.lot_size).where(organization_id: asset.organization_id).count)
  end

  it 'should be able to search by Percent Operational' do
    asset = create(:bus_shelter, :pcnt_operational => 90)

    searcher = AssetSearcher.new(:pcnt_operational => asset.pcnt_operational , :pcnt_operational_comparator => '0', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where(pcnt_operational: asset.pcnt_operational).where(organization_id: asset.organization_id).count)

    searcher = AssetSearcher.new(:pcnt_operational => asset.pcnt_operational , :pcnt_operational_comparator => '-1', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where('pcnt_operational < ?',  asset.pcnt_operational).where(organization_id: asset.organization_id).count)

    searcher = AssetSearcher.new(:pcnt_operational => asset.pcnt_operational , :pcnt_operational_comparator => '1', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where('pcnt_operational > ?',  asset.pcnt_operational).where(organization_id: asset.organization_id).count)
  end

  it 'should be able to search by number of floors' do
    asset = create(:bus_shelter, :num_floors => 4)

    searcher = AssetSearcher.new(:num_floors => asset.num_floors , :num_floors_comparator => '0', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where(num_floors: asset.num_floors).where(organization_id: asset.organization_id).count)

    searcher = AssetSearcher.new(:num_floors => asset.num_floors , :num_floors_comparator => '-1', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where('num_floors < ?',  asset.num_floors).where(organization_id: asset.organization_id).count)

    searcher = AssetSearcher.new(:num_floors => asset.num_floors , :num_floors_comparator => '1', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where('num_floors > ?',  asset.num_floors).where(organization_id: asset.organization_id).count)
  end

  it 'should be able to search by number of elevators' do
    asset = create(:bus_shelter, :num_elevators => 4)

    searcher = AssetSearcher.new(:num_elevators => asset.num_elevators , :num_elevators_comparator => '0', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where(num_elevators: asset.num_elevators).where(organization_id: asset.organization_id).count)

    searcher = AssetSearcher.new(:num_elevators => asset.num_elevators , :num_elevators_comparator => '-1', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where('num_elevators < ?',  asset.num_elevators).where(organization_id: asset.organization_id).count)

    searcher = AssetSearcher.new(:num_elevators => asset.num_elevators , :num_elevators_comparator => '1', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where('num_elevators > ?',  asset.num_elevators).where(organization_id: asset.organization_id).count)
  end

  it 'should be able to search by number of escalators' do
    asset = create(:bus_shelter, :num_escalators => 4)

    searcher = AssetSearcher.new(:num_escalators => asset.num_escalators , :num_escalators_comparator => '0', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where(num_escalators: asset.num_escalators).where(organization_id: asset.organization_id).count)

    searcher = AssetSearcher.new(:num_escalators => asset.num_escalators , :num_escalators_comparator => '-1', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where('num_escalators < ?',  asset.num_escalators).where(organization_id: asset.organization_id).count)

    searcher = AssetSearcher.new(:num_escalators => asset.num_escalators , :num_escalators_comparator => '1', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where('num_escalators > ?',  asset.num_escalators).where(organization_id: asset.organization_id).count)
  end

  it 'should be able to search by number of structures' do
    asset = create(:bus_shelter, :num_structures => 4)

    searcher = AssetSearcher.new(:num_structures => asset.num_structures , :num_structures_comparator => '0', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where(num_structures: asset.num_structures).where(organization_id: asset.organization_id).count)

    searcher = AssetSearcher.new(:num_structures => asset.num_structures , :num_structures_comparator => '-1', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where('num_structures < ?',  asset.num_structures).where(organization_id: asset.organization_id).count)

    searcher = AssetSearcher.new(:num_structures => asset.num_structures , :num_structures_comparator => '1', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where('num_structures > ?',  asset.num_structures).where(organization_id: asset.organization_id).count)
  end

  it 'should be able to search by number of private parking spaces' do
    asset = create(:bus_shelter,:num_parking_spaces_private => 4)

    searcher = AssetSearcher.new(:num_parking_spaces_private => asset.num_parking_spaces_private , :num_parking_spaces_private_comparator => '0', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where(num_parking_spaces_private: asset.num_parking_spaces_private).where(organization_id: asset.organization_id).count)

    searcher = AssetSearcher.new(:num_parking_spaces_private => asset.num_parking_spaces_private , :num_parking_spaces_private_comparator => '-1', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where('num_parking_spaces_private < ?',  asset.num_parking_spaces_private).where(organization_id: asset.organization_id).count)

    searcher = AssetSearcher.new(:num_parking_spaces_private => asset.num_parking_spaces_private , :num_parking_spaces_private_comparator => '1', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where('num_parking_spaces_private > ?',  asset.num_parking_spaces_private).where(organization_id: asset.organization_id).count)
  end

  it 'should be able to search by number of public parking spaces' do
    asset = create(:bus_shelter, :num_parking_spaces_public => 4)

    searcher = AssetSearcher.new(:num_parking_spaces_public => asset.num_parking_spaces_public , :num_parking_spaces_public_comparator => '0', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where(num_parking_spaces_public: asset.num_parking_spaces_public).where(organization_id: asset.organization_id).count)

    searcher = AssetSearcher.new(:num_parking_spaces_public => asset.num_parking_spaces_public , :num_parking_spaces_public_comparator => '-1', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where('num_parking_spaces_public < ?',  asset.num_parking_spaces_public).where(organization_id: asset.organization_id).count)

    searcher = AssetSearcher.new(:num_parking_spaces_public => asset.num_parking_spaces_public , :num_parking_spaces_public_comparator => '1', :organization_id => asset.organization_id)
    expect(searcher.data.count).to eq(Asset.where('num_parking_spaces_public > ?',  asset.num_parking_spaces_public).where(organization_id: asset.organization_id).count)
  end

end
