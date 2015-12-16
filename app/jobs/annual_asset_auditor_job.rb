#-------------------------------------------------------------------------------
# Basic Job runner that rips through an asset inventory and runs a AnnualAssetAuditService
# on each. Results are stored in the audits table
#-------------------------------------------------------------------------------
class AnnualAssetAuditorJob < ActivityJob

  def run

    # Create an audit service and provide the context (activity)
    service = AnnualAssetAuditService.new(@context)
    # Loop through eaech org at a time
    TransitOperator.all.each do |org|
      Rails.logger.debug("Running AnnualAssetUpdateAuditJob for #{org}")
      write_to_activity_log org, "Executing #{self.class.name}"
      # Only process operational assets
      org.assets.operational.pluck(:object_key).each do |obj_key|
        asset = Asset.find_by(object_key: obj_key)
        service.audit(asset)
      end

    end
  end

  def check
    super
  end

  def clean_up
    super
    Rails.logger.debug "Completed AnnualAssetAuditorJob at #{Time.now.to_s}"
  end

  def prepare
    super
    Rails.logger.debug "Executing AnnualAssetAuditorJob at #{Time.now.to_s}"
  end
end
