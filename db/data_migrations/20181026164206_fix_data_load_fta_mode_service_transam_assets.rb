class FixDataLoadFtaModeServiceTransamAssets < ActiveRecord::DataMigration
  def up
    if Infrastructure.count == 0 # no client has infrastructure except sfrta

      AssetsFtaModeType.where(asset_id: Facility.pluck(:asset_id)).update_all(transam_asset_type: 'Facility')
      AssetsFtaModeType.where(asset_id: ServiceVehicle.pluck(:asset_id)).update_all(transam_asset_type: 'ServiceVehicle')

      if Facility.where(id: AssetsFtaModeType.where(asset_id: nil).select(:transam_asset_id)).count == 0 # make sure all new assets are vehicles
        AssetsFtaModeType.where(asset_id: nil).where.not(transam_asset_id: nil).update_all(transam_asset_type: 'ServiceVehicle')
      end

      AssetsFtaServiceType.where.not(transam_asset_id: nil).update_all(transam_asset_type: 'RevenueVehicle')

      # deal with possible same fta mode type and fta service type
      AssetsFtaModeType.where.not(transam_asset_id: nil).group(:transam_asset_type, :transam_asset_id, :fta_mode_type_id).having('COUNT(*) > 1').count.keys.each do |asset_mode|
        asset_mode[0].constantize.find(asset_mode[1]).assets_fta_mode_types.find_by(is_primary: [false, nil]).delete if asset_mode[0].present?
      end
      AssetsFtaServiceType.where.not(transam_asset_id: nil).group(:transam_asset_type, :transam_asset_id, :fta_service_type_id).having('COUNT(*) > 1').count.keys.each do |asset_service_type|
        asset_service_type[0].constantize.find(asset_service_type[1]).assets_fta_service_types.find_by(is_primary: [false, nil]).delete if asset_service_type[0].present?
      end
    end


  end
end