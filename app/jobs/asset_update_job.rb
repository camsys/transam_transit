#------------------------------------------------------------------------------
#
# AssetUpdateJob
#
# Updates all components of an asset
#
#------------------------------------------------------------------------------
class AssetUpdateJob < AbstractAssetUpdateJob

  attr_accessor :perform_sogr_update

  def execute_job(asset)
    if asset.type_of? :vehicle
      asset.update_mileage
      asset.update_usage_codes
    end

    if asset.type_of? :support_vehicle
      asset.update_mileage
    end

    if asset.type_of? :rolling_stock
      asset.update_location
      asset.update_usage_metrics
      asset.update_operations_metrics
      asset.update_storage_method
    end

    # generic asset updates
    asset.update_condition
    asset.update_maintenance_provider
    asset.update_service_status
    asset.update_scheduled_replacement
    asset.update_scheduled_disposition
    asset.update_estimated_value

    if perform_sogr_update
      asset.update_sogr
    end
  end

  def prepare
    Rails.logger.debug "Executing AssetUpdateJob at #{Time.now.to_s} for Asset #{object_key}"
  end

  def initialize(object_key, perform_sogr_update = false)
    super(object_key)
    self.perform_sogr_update = perform_sogr_update
  end

end
