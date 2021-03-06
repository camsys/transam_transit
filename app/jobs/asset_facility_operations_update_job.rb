# --------------------------------
# # DEPRECATED see TTPLAT-1832 or https://wiki.camsys.com/pages/viewpage.action?pageId=51183790
# --------------------------------

#------------------------------------------------------------------------------
#
# AssetFacilityOperationsUpdateJob
#
# Updates a facility's operational characteristics
#
#------------------------------------------------------------------------------
class AssetFacilityOperationsUpdateJob < AbstractAssetUpdateJob

  def execute_job(asset)
    asset.update_facility_operations_metrics
  end

  def prepare
    Rails.logger.info "Executing AssetFacilityOperationsUpdateJob at #{Time.now.to_s} for Asset #{object_key}"
  end

end
