# --------------------------------
# # DEPRECATED see TTPLAT-1832 or https://wiki.camsys.com/pages/viewpage.action?pageId=51183790
# --------------------------------
#
# #------------------------------------------------------------------------------
#
# AssetUsageCodesUpdateJob
#
# Updates an assets condition
#
#------------------------------------------------------------------------------
class AssetUsageCodesUpdateJob < AbstractAssetUpdateJob
  
  def execute_job(asset)       
    asset.update_usage_codes
  end

  def prepare
    Rails.logger.debug "Executing AssetUsageCodesUpdateJob at #{Time.now.to_s} for Asset #{object_key}"    
  end
  
end