require 'rails_helper'

RSpec.describe MaintenanceProviderUpdateEvent, :type => :model do

  # TTPLAT-3112: survivor fixture. The event is created through TransitAsset#maintenance_provider_updates
  # (transit_asset.rb:24, `:as => :transam_asset`) rather than the legacy :buslike_asset (`:class => :asset`).
  let(:organization) { create(:organization) }
  let(:test_asset) do
    create(:policy, :organization => organization, :parent => create(:parent_policy))
    create(:revenue_vehicle, :organization => organization)
  end
  let(:test_event) { test_asset.maintenance_provider_updates.create!(attributes_for(:maintenance_provider_update_event)) }

  describe 'associations' do
    it 'has a type' do
      expect(test_event).to belong_to(:maintenance_provider_type)
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
    expect(test_event.get_update.to_s).to eq("Maintained by #{test_event.maintenance_provider_type}")
  end

  it '.set_defaults' do
    # The comparison target, an asset-level maintenance_provider_type, exists only on legacy Asset (the
    # deprecated TransamTransitAsset mixin, lib/transam_transit/transam_transit_asset.rb:40). No survivor
    # carries it. Left for a decision rather than rewritten -- see the TTPLAT-3112 report.
    skip 'TTPLAT-3112: survivors have no asset-level maintenance_provider_type to compare against'
    test_event.maintenance_provider_type = nil
    test_event.reload
    expect(test_event.asset_event_type).to eq(AssetEventType.find_by(:class_name => 'MaintenanceProviderUpdateEvent'))
    expect(test_event.maintenance_provider_type).to eq(test_event.transam_asset.maintenance_provider_type)
  end
end
