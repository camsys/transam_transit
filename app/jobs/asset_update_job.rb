#------------------------------------------------------------------------------
#
# AssetUpdateJob
#
# Updates all components of an asset
#
#------------------------------------------------------------------------------
class AssetUpdateJob < AbstractAssetUpdateJob

  attr_accessor :perform_sogr_update

  # If a generic Asset is passed, we run an incomplete list of update methods
  def execute_job(typed_asset)
    update_methods = typed_asset.update_methods
    
    # Is SOGR status expensive to update?
    unless perform_sogr_update
      update_methods.remove(:update_sogr)
    end
    
    update_methods.each do |method|
      typed_asset.send(method)
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
