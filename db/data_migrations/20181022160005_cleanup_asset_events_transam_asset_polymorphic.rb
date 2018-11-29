class CleanupAssetEventsTransamAssetPolymorphic < ActiveRecord::DataMigration
  def up
    AssetEventType.all.each do |asset_event_type|
      event_class_name = asset_event_type.class_name

      if event_class_name == 'FacilityOperationsUpdateEvent'
        AssetEvent.where(asset_event_type: asset_event_type).update_all(transam_asset_type: 'Facility')
      elsif event_class_name == 'MaintenanceProviderUpdateEvent'
        AssetEvent.where(asset_event_type: asset_event_type).update_all(transam_asset_type: 'TransitAsset')
      elsif event_class_name == 'PerformanceRestrictionUpdateEvent'
        AssetEvent.where(asset_event_type: asset_event_type).update_all(transam_asset_type: 'Infrastructure')
      elsif ['MileageUpdateEvent', 'OperationsUpdateEvent', 'StorageMethodUpdateEvent', 'UsageCodesUpdateEvent', 'VehicleUsageUpdateEvent'].include? event_class_name
        AssetEvent.where(asset_event_type: asset_event_type).update_all(transam_asset_type: 'ServiceVehicle')
      else
        AssetEvent.where(asset_event_type: asset_event_type).update_all(transam_asset_type: 'TransamAsset')
      end
    end
  end
end