require 'rails_helper'

RSpec.describe MaintenanceProviderUpdateEvent, :type => :model do

  let(:test_event) { create(:buslike_asset, :maintenance_provider_type => create(:maintenance_provider_type)).maintenance_provider_updates.create!(attributes_for(:maintenance_provider_update_event)) }

  let(:test_asset) { create(:buslike_asset, ) }

  describe 'associations' do
    it 'has a type' do
      expect(MaintenanceProviderUpdateEvent.column_names).to include('maintenance_provider_type_id')
    end
  end
  describe 'validations' do
    it 'must have a type' do
      test_event.maintenance_provider_type = nil
      expect(test_event.valid?).to be false
    end
  end

  it '#allowable_params' do
    expect(MaintenanceProviderUpdateEvent.allowable_params).to eq([
      :maintenance_provider_type_id
    ])
  end
  it '#asset_event_type' do
    expect(MaintenanceProviderUpdateEvent.asset_event_type).to eq(AssetEventType.find_by(:class_name => 'MaintenanceProviderUpdateEvent'))
  end

  it '.get_update' do
    expect(test_event.get_update).to eq(test_event.maintenance_provider_type.to_s)
  end

  it '.set_defaults' do
    test_event.maintenance_provider_type = nil
    test_event.reload
    expect(test_event.asset_event_type).to eq(AssetEventType.find_by(:class_name => 'MaintenanceProviderUpdateEvent'))
    expect(test_event.maintenance_provider_type).to eq(test_event.asset.maintenance_provider_type)
  end
end
