class SetBaseTransamAssetAssetEvents < ActiveRecord::DataMigration
  def up
    AssetEvent.unscoped.where(transam_asset_type: 'TransamAsset')
        .joins('INNER JOIN transam_assets ON transam_assets.id = asset_events.transam_asset_id AND transam_asset_type="TransamAsset"')
        .update_all("base_transam_asset_id = transam_assets.id")

    AssetEvent.unscoped.where(transam_asset_type: 'TransitAsset')
        .joins('INNER JOIN transit_assets ON transit_assets.id = asset_events.transam_asset_id AND transam_asset_type="TransitAsset"')
        .joins("LEFT OUTER JOIN `transam_assets` ON `transam_assets`.`transam_assetible_id` = `transit_assets`.`id` AND `transam_assets`.`transam_assetible_type` = 'TransitAsset'")
        .update_all("base_transam_asset_id = transam_assets.id")

    AssetEvent.unscoped.where(transam_asset_type: 'ServiceVehicle')
        .joins('INNER JOIN service_vehicles ON service_vehicles.id = asset_events.transam_asset_id AND transam_asset_type="ServiceVehicle"')
        .joins("LEFT OUTER JOIN `transit_assets` ON `transit_assets`.`transit_assetible_id` = `service_vehicles`.`id` AND `transit_assets`.`transit_assetible_type` = 'ServiceVehicle'")
        .joins("LEFT OUTER JOIN `transam_assets` ON `transam_assets`.`transam_assetible_id` = `transit_assets`.`id` AND `transam_assets`.`transam_assetible_type` = 'TransitAsset'")
        .update_all("base_transam_asset_id = transam_assets.id")

    AssetEvent.unscoped.where(transam_asset_type: 'Facility')
        .joins('INNER JOIN facilities ON facilities.id = asset_events.transam_asset_id AND transam_asset_type="Facility"')
        .joins("LEFT OUTER JOIN `transit_assets` ON `transit_assets`.`transit_assetible_id` = `facilities`.`id` AND `transit_assets`.`transit_assetible_type` = 'Facility'")
        .joins("LEFT OUTER JOIN `transam_assets` ON `transam_assets`.`transam_assetible_id` = `transit_assets`.`id` AND `transam_assets`.`transam_assetible_type` = 'TransitAsset'")
        .update_all("base_transam_asset_id = transam_assets.id")

  end
end