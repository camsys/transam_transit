require 'rails_helper'

RSpec.describe RevenueVehicle, type: :model do


  #Handle requirements for creating a revenue vehicle
  before(:each) do
    @organization = create(:organization)
    # TTPLAT-3072 P1 §2.3: extracted from the hand-rolled parent_policy + type/subtype-rule chain
    # to the existing :parent_policy factory, which seeds a rule for every AssetType/AssetSubtype
    # instead of just AssetType.first/AssetSubtype.first. Confirmed this doesn't change this
    # example's behavior: Policy#asset_type_rule/#asset_subtype_rule always look up an exact
    # match by id (never `.first`/`.all`), so the extra seeded rows are simply unused here.
    parent_policy = create(:parent_policy)
    policy = create(:policy, :organization => @organization, :parent => parent_policy)
    @revenue_vehicle =  create(:revenue_vehicle, organization: @organization) 
  end

  # TTPLAT-2413
  it 'should save without error' do
    @revenue_vehicle.save!
  end
  it 'should not allow a duplicate serial_number' do
    # serial_number is now sequenced on the :revenue_vehicle factory (TTPLAT-3072 P1 §2.1), so the
    # collision this example asserts on no longer happens by default. Force it explicitly by reusing
    # @revenue_vehicle's serial_number so this example still tests what it claims to test.
    expect{create(:revenue_vehicle, asset_tag: 'new tag', serial_number: @revenue_vehicle.serial_number, organization: @organization)}
      .to raise_error(ActiveRecord::RecordInvalid,'Validation failed: Serial number has already been taken')
  end

  it { should respond_to :rowify }

  it 'knows how to turn itself into a row for a table' do
    expect(@revenue_vehicle.rowify[:asset_id][:data]).to eq(@revenue_vehicle.asset_tag)
    expect(@revenue_vehicle.rowify[:asset_id][:label]).to eq("Asset ID")
    expect(@revenue_vehicle.rowify[:org_name][:data]).to eq(@revenue_vehicle.organization.short_name)
    expect(@revenue_vehicle.rowify[:vin][:data]).to eq(@revenue_vehicle.serial_number)
    expect(@revenue_vehicle.rowify[:manufacturer][:data]).to eq(@revenue_vehicle.manufacturer_name)
    expect(@revenue_vehicle.rowify[:model][:data]).to eq(@revenue_vehicle.manufacturer_model_name)
    expect(@revenue_vehicle.rowify[:year][:data]).to eq(@revenue_vehicle.manufacture_year)
    expect(@revenue_vehicle.rowify[:type][:data]).to eq(@revenue_vehicle.fta_type.name)
    expect(@revenue_vehicle.rowify[:subtype][:data]).to eq(@revenue_vehicle.asset_subtype.name)
    expect(@revenue_vehicle.rowify[:service_status][:data]).to eq(@revenue_vehicle.service_status_updates.order(:event_date).last)
    expect(@revenue_vehicle.rowify[:last_life_cycle_action][:data]).to eq(@revenue_vehicle.history.first.try(:asset_event_type).try(:name))
    expect(@revenue_vehicle.rowify[:life_cycle_action_date][:data]).to eq(@revenue_vehicle.history.first.try(:event_date))
  end

end