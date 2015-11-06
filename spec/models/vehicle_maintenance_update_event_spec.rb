require 'rails_helper'

RSpec.describe VehicleMaintenanceUpdateEvent, :type => :model do

  let(:test_event) { create(:vehicle_maintenance_update_event) }

  describe 'associations' do
    it 'has a type' do
      expect(VehicleMaintenanceUpdateEvent.column_names).to include('maintenance_type_id')
    end
  end
  describe 'validations' do
    it 'must have a type' do
      test_event.maintenance_type = nil
      expect(test_event.valid?).to be false
    end
  end

  it '#allowable_params' do
    expect(VehicleMaintenanceUpdateEvent.allowable_params).to eq([:maintenance_type_id,:current_mileage])
  end
  it '#asset_event_type' do
    expect(VehicleMaintenanceUpdateEvent.asset_event_type).to eq(AssetEventType.find_by(:class_name => 'VehicleMaintenanceUpdateEvent'))
  end

  it '.get_update' do
    expect(test_event.get_update).to eq("#{test_event.maintenance_type.to_s} at #{test_event.current_mileage}")
  end

  it '.set_defaults' do
    expect(VehicleMaintenanceUpdateEvent.new.asset_event_type).to eq(AssetEventType.find_by(:class_name => 'VehicleMaintenanceUpdateEvent'))
    expect(VehicleMaintenanceUpdateEvent.new.current_mileage).to eq(0)
  end
end
