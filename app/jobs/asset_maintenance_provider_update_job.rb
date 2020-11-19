# --------------------------------
# # DEPRECATED see TTPLAT-1832 or https://wiki.camsys.com/pages/viewpage.action?pageId=51183790
# --------------------------------
#
# #------------------------------------------------------------------------------
#
# AssetMaintenanceProviderUpdateJob
#
# Updates an assets condition
#
#------------------------------------------------------------------------------
class AssetMaintenanceProviderUpdateJob < AbstractAssetUpdateJob
  
  def execute_job(asset)     
    asset.update_maintenance_provider
  end

  def prepare
    Rails.logger.debug "Executing AssetMaintenanceProviderUpdateJob at #{Time.now.to_s} for Asset #{object_key}"    
  end
  
end