class FixDataLoadFtaModeServiceTransamAssets < ActiveRecord::DataMigration
  def up
    if Infrastructure.count == 0 # no client has infrastructure except sfrta

      Facility.where(transit_assets: {asset_id: AssetsFtaModeType.select(:asset_id)}).update_all(transam_asset_type: 'Facility')
      ServiceVehicle.where(transit_assets: {asset_id: AssetsFtaModeType.select(:asset_id)}).update_all(transam_asset_type: 'ServiceVehicle')
      if Facility.where(id: AssetsFtaModeType.where(asset_id: nil).select(:transam_asset_id)).count == 0 # make sure all new assets are vehicles
        AssetsFtaModeType.where(asset_id: nil).update_all(transam_asset_type: 'ServiceVehicle')
      end

      AssetsFtaServiceType.update_all(transam_asset_type: 'RevenueVehicle')
    end
  end
end