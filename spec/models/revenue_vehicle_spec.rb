require 'rails_helper'

RSpec.describe RevenueVehicle, type: :model do


  #TODO: It's unclear how much of this policy stuff is needed. It isn't being tested, but it required in order for transit assets to be created.
  before(:each) do
    @organization = create(:organization)
    parent_policy = create(:policy, :organization => create(:organization))
    create(:policy_asset_type_rule, :policy => parent_policy, :asset_type => AssetType.first)
    create(:policy_asset_subtype_rule, :policy => parent_policy, :asset_subtype => AssetSubtype.first)
    policy = create(:policy, :organization => @organization, :parent => parent_policy)
    create(:policy_asset_type_rule, :policy => policy, :asset_type => AssetType.first)
    create(:policy_asset_subtype_rule, :policy => policy, :asset_subtype => AssetSubtype.first, :fuel_type_id => 1)
    @revenue_vehicle =  create(:revenue_vehicle, organization: @organization) 
    @mileage_update_event = create(:mileage_update_event, :asset => @test_asset)

  end

  it { should respond_to :rowify }

  it 'knows how to turn itself into a row for a table' do
    expect(@revenue_vehicle.rowify["Asset Id"]).to eq(@revenue_vehicle.asset_tag)
    expect(@revenue_vehicle.rowify["Organization"]).to eq(@revenue_vehicle.organization.short_name)
    expect(@revenue_vehicle.rowify["VIN"]).to eq(@revenue_vehicle.serial_number)
    expect(@revenue_vehicle.rowify["Manufacturer"]).to eq(@revenue_vehicle.manufacturer.name)
    expect(@revenue_vehicle.rowify["Model"]).to eq(@revenue_vehicle.model_name.to_s)
    expect(@revenue_vehicle.rowify["Year"]).to eq(@revenue_vehicle.manufacture_year.to_s)
    expect(@revenue_vehicle.rowify["Type"]).to eq(@revenue_vehicle.fta_type.name)
    expect(@revenue_vehicle.rowify["Subtype"]).to eq(@revenue_vehicle.asset_subtype.name)
    expect(@revenue_vehicle.rowify["Service Status"]).to eq(@revenue_vehicle.service_status_updates.order(:event_date).last.to_s)
    expect(@revenue_vehicle.rowify["ESL"]).to eq(@revenue_vehicle.esl_category.name)
    expect(@revenue_vehicle.rowify["Last Life Cycle Action"]).to eq(@revenue_vehicle.history.first.try(:asset_event_type).try(:name).to_s)
    expect(@revenue_vehicle.rowify["Life Cycle Action Date"]).to eq(@revenue_vehicle.history.first.try(:event_date).to_s)
  end

end