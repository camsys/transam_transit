class CleanupAssetEventsTransamAssetPolymorphic < ActiveRecord::DataMigration
  def up
    AssetEvent.all.each do |asset_event|
      typed_event = AssetEvent.as_typed_event(asset_event)

      if typed_event.class.to_s == 'FacilityOperationsUpdateEvent'
        typed_event.update_columns(transam_asset_type: 'Facility')
      elsif typed_event.class.to_s == 'MaintenanceProviderUpdateEvent'
        typed_event.update_columns(transam_asset_type: 'TransitAsset')
      elsif typed_event.class.to_s == 'PerformanceRestrictionUpdateEvent'
        typed_event.update_columns(transam_asset_type: 'Infrastructure')
      elsif ['MileageUpdateEvent', 'OperationsUpdateEvent', 'StorageMethodUpdateEvent', 'UsageCodesUpdateEvent', 'VehicleUsageUpdateEvent']
        typed_event.update_columns(transam_asset_type: 'ServiceVehicle')
      else
        typed_event.update_columns(transam_asset_type: 'TransamAsset')
      end
    end
  end
end