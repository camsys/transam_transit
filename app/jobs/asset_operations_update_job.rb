#------------------------------------------------------------------------------
#
# AssetOperationsUpdateJob
#
# Updates an assets operational characteristics
#
#------------------------------------------------------------------------------
class AssetOperationsUpdateJob < AbstractAssetUpdateJob
  
  def execute_job(asset)      
    asset.update_operations_metrics
  end

  def prepare
    Rails.logger.info "Executing AssetOperationsUpdateJob at #{Time.now.to_s} for Asset #{object_key}"    
  end
  
end