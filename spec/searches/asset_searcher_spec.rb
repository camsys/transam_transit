require 'rails_helper'

RSpec.describe AssetSearcher, :type => :model do
  let(:asset) { create(:equipment_asset, :organization_id => 1) }
  let(:searcher) { AssetSearcher.new(:organization_id => asset.organization_id, :class_name => "Equipment") }
  let(:bus) { create(:bus) }

  #------------------------------------------------------------------------------
  #
  # Simple Equality Searches
  #
  #------------------------------------------------------------------------------

  it 'should be able to search by fuel type' do
    searcher.fuel_type_id = asset.fuel_type_id

    expect(searcher.data.count).to eq(Asset.joins(:asset_type).where(asset_types: { class_name: "Equipment" }).where(fuel_type_id: asset.fuel_type_id).where(organization_id: asset.organization_id))
  end

  it 'should be able to search by storage method type' do
    asset.update!(:storage_method_type_id => 1)
    searcher.storage_method_type_id = asset.storage_method_type_id

    expect(searcher.data.count).to eq(Asset.joins(:asset_type).where(asset_types: { class_name: "Equipment" }).where(storage_method_type_id: asset.storage_method_type_id).where(organization_id: asset.organization_id))
  end

  it 'should be able to search by fta bus mode type' do
    asset.update!(:fta_bus_mode_id => 1)
    searcher.fta_bus_mode_id = asset.fta_bus_mode_id

    expect(searcher.data.count).to eq(Asset.joins(:asset_type).where(asset_types: { class_name: "Equipment" }).where(asset_types: { class_name: "Equipment" }).where(fta_bus_mode_id: asset.fta_bus_mode_id).where(organization_id: asset.organization_id))
  end

  it 'should be able to search by fta ownership type' do
    searcher.fta_ownership_type_id = asset.fta_ownership_type_id

    expect(searcher.data.count).to eq(Asset.joins(:asset_type).where(asset_types: { class_name: "Equipment" }).where(fta_ownership_type_id: asset.fta_ownership_type_id).where(organization_id: asset.organization_id))
  end

  it 'should be able to search by fta vehicle type' do
    searcher.fta_vehicle_type_id = asset.fta_vehicle_type_id

    expect(searcher.data.count).to eq(Asset.joins(:asset_type).where(asset_types: { class_name: "Equipment" }).where(fta_vehicle_type_id: asset.fta_vehicle_type_id).where(organization_id: asset.organization_id))
  end

  it 'should be able to search by fta service type' do
    asset.update!(:fta_service_type_id => 1)
    searcher.fta_service_type_id = asset.fta_service_type_id

    expect(searcher.data.count).to eq(Asset.joins(:asset_type).where(asset_types: { class_name: "Equipment" }).where(fta_service_type_id: asset.fta_service_type_id).where(organization_id: asset.organization_id))
  end

  #------------------------------------------------------------------------------
  #
  # Comparator Searches
  #
  #------------------------------------------------------------------------------

  it 'should be able to search by vehicle length' do
    searcher.vehicle_length = asset.vehicle_length
    searcher.vehicle_length_comparator = '0'
    expect(searcher.data.count).to eq(Asset.joins(:asset_type).where(asset_types: { class_name: "Equipment" }).where(vehicle_length: asset.vehicle_length).where(organization_id: asset.organization_id))

    searcher.vehicle_length_comparator = '-1'
    expect(searcher.data.count).to eq(Asset.joins(:asset_type).where(asset_types: { class_name: "Equipment" }).where('vehicle_length < ?',  asset.vehicle_length).where(organization_id: asset.organization_id))

    searcher.vehicle_length_comparator = '1'
    expect(searcher.data.count).to eq(Asset.joins(:asset_type).where(asset_types: { class_name: "Equipment" }).where('vehicle_length > ?',  asset.vehicle_length).where(organization_id: asset.organization_id))
  end

  it 'should be able to search by seating capacity' do
    searcher.seating_capacity = asset.seating_capacity
    searcher.seating_capacity_comparator = '0'
    expect(searcher.data.count).to eq(Asset.joins(:asset_type).where(asset_types: { class_name: "Equipment" }).where(seating_capacity: asset.seating_capacity).where(organization_id: asset.organization_id))

    searcher.vehicle_length_comparator = '-1'
    expect(searcher.data.count).to eq(Asset.joins(:asset_type).where(asset_types: { class_name: "Equipment" }).where('seating_capacity < ?',  asset.seating_capacity).where(organization_id: asset.organization_id))

    searcher.vehicle_length_comparator = '1'
    expect(searcher.data.count).to eq(Asset.joins(:asset_type).where(asset_types: { class_name: "Equipment" }).where('seating_capacity > ?',  asset.seating_capacity).where(organization_id: asset.organization_id))
  end

  it 'should be able to search by standing capacity' do
    searcher.standing_capacity = asset.standing_capacity
    searcher.standing_capacity_comparator = '0'
    expect(searcher.data.count).to eq(Asset.joins(:asset_type).where(asset_types: { class_name: "Equipment" }).where(standing_capacity: asset.seating_capacity).where(organization_id: asset.organization_id))

    searcher.standing_capacity_comparator = '-1'
    expect(searcher.data.count).to eq(Asset.joins(:asset_type).where(asset_types: { class_name: "Equipment" }).where('standing_capacity < ?',  asset.seating_capacity).where(organization_id: asset.organization_id))

    searcher.standing_capacity_comparator = '1'
    expect(searcher.data.count).to eq(Asset.joins(:asset_type).where(asset_types: { class_name: "Equipment" }).where('standing_capacity > ?',  asset.seating_capacity).where(organization_id: asset.organization_id))
  end

  it 'should be able to search by wheelchair capacity' do
    searcher.wheelchair_capacity = asset.wheelchair_capacity
    searcher.wheelchair_capacity_comparator = '0'
    expect(searcher.data.count).to eq(Asset.joins(:asset_type).where(asset_types: { class_name: "Equipment" }).where(wheelchair_capacity: asset.wheelchair_capacity).where(organization_id: asset.organization_id))

    searcher.wheelchair_capacity_comparator = '-1'
    expect(searcher.data.count).to eq(Asset.joins(:asset_type).where(asset_types: { class_name: "Equipment" }).where('wheelchair_capacity < ?',  asset.seating_capacity).where(organization_id: asset.organization_id))

    searcher.wheelchair_capacity_comparator = '1'
    expect(searcher.data.count).to eq(Asset.joins(:asset_type).where(asset_types: { class_name: "Equipment" }).where('wheelchair_capacity > ?',  asset.seating_capacity).where(organization_id: asset.organization_id))
  end

  it 'should be able to search by gross vehicle weight' do
    searcher.gross_vehicle_weight = asset.gross_vehicle_weight
    searcher.gross_vehicle_weight_comparator = '0'
    expect(searcher.data.count).to eq(Asset.joins(:asset_type).where(asset_types: { class_name: "Equipment" }).where(gross_vehicle_weight: asset.gross_vehicle_weight).where(organization_id: asset.organization_id))

    searcher.gross_vehicle_weight_comparator = '-1'
    expect(searcher.data.count).to eq(Asset.joins(:asset_type).where(asset_types: { class_name: "Equipment" }).where('gross_vehicle_weight < ?',  asset.gross_vehicle_weight).where(organization_id: asset.organization_id))

    searcher.gross_vehicle_weight_comparator = '1'
    expect(searcher.data.count).to eq(Asset.joins(:asset_type).where(asset_types: { class_name: "Equipment" }).where('gross_vehicle_weight > ?',  asset.gross_vehicle_weight).where(organization_id: asset.organization_id))
  end

  it 'should be able to search by rebuild year' do
    asset.update!(:rebuild_year => Date.today.year)

    searcher.rebuild_year = asset.rebuild_year
    searcher.rebuild_year_comparator = '0'
    expect(searcher.data.count).to eq(Asset.joins(:asset_type).where(asset_types: { class_name: "Equipment" }).where(rebuild_year: asset.gross_vehicle_weight).where(organization_id: asset.organization_id))

    searcher.rebuild_year_comparator = '-1'
    expect(searcher.data.count).to eq(Asset.joins(:asset_type).where(asset_types: { class_name: "Equipment" }).where('rebuild_year < ?',  asset.rebuild_year).where(organization_id: asset.organization_id))

    searcher.rebuild_year_comparator = '1'
    expect(searcher.data.count).to eq(Asset.joins(:asset_type).where(asset_types: { class_name: "Equipment" }).where('rebuild_year > ?',  asset.rebuild_year).where(organization_id: asset.organization_id))
  end

  it 'should be able to search by current mileage' do
    asset.update!(:current_mileage => 10000)

    searcher.current_mileage = asset.current_mileage
    searcher.current_mileage_comparator = '0'
    expect(searcher.data.count).to eq(Asset.joins(:asset_type).where(asset_types: { class_name: "Equipment" }).where(current_mileage: asset.current_mileage).where(organization_id: asset.organization_id))

    searcher.current_mileage_comparator = '-1'
    expect(searcher.data.count).to eq(Asset.joins(:asset_type).where(asset_types: { class_name: "Equipment" }).where('current_mileage < ?',  asset.current_mileage).where(organization_id: asset.organization_id))

    searcher.current_mileage_comparator = '1'
    expect(searcher.data.count).to eq(Asset.joins(:asset_type).where(asset_types: { class_name: "Equipment" }).where('rebuild_year > ?',  asset.current_mileage).where(organization_id: asset.organization_id))
  end

  #------------------------------------------------------------------------------
  #
  # Checkbox Searches
  #
  #------------------------------------------------------------------------------
  it 'should be able to search by fta contingency fleet' do
    asset.update!(:fta_contingency_fleet => true)
    searcher.fta_service_type_id = asset.fta_contingency_fleet

    expect(searcher.data.count).to eq(Asset.joins(:asset_type).where(asset_types: { class_name: "Equipment" }).where(fta_service_type_id: asset.fta_contingency_fleet).where(organization_id: asset.organization_id))
  end

  it 'should be able to search by ada accessibility' do
    asset.update!(:ada_accessible_ramp => true, :ada_accessible_lift => false)
    searcher.ada_accessible_ramp = asset.ada_accessible_ramp

    expect(searcher.data.count).to eq(Asset.joins(:asset_type).where(asset_types: { class_name: "Equipment" }).where('ada_accessible_ramp = 1 OR ada_accessible_lift = 1')
      .where(organization_id: asset.organization_id))
  end

end
