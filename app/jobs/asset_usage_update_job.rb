#------------------------------------------------------------------------------
#
# AssetUsageUpdateJob
#
# Updates an assets usage metrics
#
#------------------------------------------------------------------------------
class AssetUsageUpdateJob < AbstractAssetUpdateJob
    
  def execute_job(asset)     
    asset.update_usage_metrics
  end

  def prepare
    Rails.logger.info "Executing AssetUsageUpdateJob at #{Time.now.to_s} for Asset #{object_key}"    
  end
  
end