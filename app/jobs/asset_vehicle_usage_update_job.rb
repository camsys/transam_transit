#------------------------------------------------------------------------------
#
# AssetVehicleUsageUpdateJob
#
# Updates an vehicle's usage metrics
#
#------------------------------------------------------------------------------
class AssetVehicleUsageUpdateJob < AbstractAssetUpdateJob

  def execute_job(asset)
    asset.update_vehicle_usage_metrics
  end

  def prepare
    Rails.logger.info "Executing AssetVehicleUsageUpdateJob at #{Time.now.to_s} for Asset #{object_key}"
  end

end
