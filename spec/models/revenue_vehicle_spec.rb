require 'rails_helper'

RSpec.describe RevenueVehicle, type: :model do


  #Handle requirements for creating a revenue vehicle
  before(:each) do
    @organization = create(:organization)
    parent_policy = create(:policy, :organization => create(:organization))
    create(:policy_asset_type_rule, :policy => parent_policy, :asset_type => AssetType.first)
    create(:policy_asset_subtype_rule, :policy => parent_policy, :asset_subtype => AssetSubtype.first)
    policy = create(:policy, :organization => @organization, :parent => parent_policy)
    @revenue_vehicle =  create(:revenue_vehicle, organization: @organization) 
  end

  it { should respond_to :rowify }

  it 'knows how to turn itself into a row for a table' do
    expect(@revenue_vehicle.rowify[:asset_id][:data]).to eq(@revenue_vehicle.asset_tag)
    expect(@revenue_vehicle.rowify[:asset_id][:label]).to eq("Asset ID")
    expect(@revenue_vehicle.rowify[:org_name][:data]).to eq(@revenue_vehicle.organization.short_name)
    expect(@revenue_vehicle.rowify[:vin][:data]).to eq(@revenue_vehicle.serial_number)
    expect(@revenue_vehicle.rowify[:manufacturer][:data]).to eq(@revenue_vehicle.manufacturer.name)
    expect(@revenue_vehicle.rowify[:model][:data]).to eq(@revenue_vehicle.model_name.to_s)
    expect(@revenue_vehicle.rowify[:year][:data]).to eq(@revenue_vehicle.manufacture_year.to_s)
    expect(@revenue_vehicle.rowify[:type][:data]).to eq(@revenue_vehicle.fta_type.name)
    expect(@revenue_vehicle.rowify[:subtype][:data]).to eq(@revenue_vehicle.asset_subtype.name)
    expect(@revenue_vehicle.rowify[:service_status][:data]).to eq(@revenue_vehicle.service_status_updates.order(:event_date).last.to_s)
    expect(@revenue_vehicle.rowify[:last_life_cycle_action][:data]).to eq(@revenue_vehicle.history.first.try(:asset_event_type).try(:name).to_s)
    expect(@revenue_vehicle.rowify[:life_cycle_action_date][:data]).to eq(@revenue_vehicle.history.first.try(:event_date).to_s)
  end

end