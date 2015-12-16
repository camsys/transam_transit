#-------------------------------------------------------------------------------
# AnnualAssetAuditService
#
# Performs a check to see that the asset being audited has had the following
# properties updated
#
#   Service Status      -- Must have been updated in the audit period
#   Condition           -- Must have been updated in the audit period
#   Mileage (if valid)  -- Must have been updated in the audit period
#-------------------------------------------------------------------------------
class AnnualAssetAuditService

  attr_accessor :context

  #-----------------------------------------------------------------------------
  # Takes an asset (typed or untyped) and checks the compliance and updates the
  # audit table wth the results
  #-----------------------------------------------------------------------------
  def audit a

    errors = []
    if a.nil?
      Rails.logger.debug "Asset cannot be nil"
      return errors
    end

    # Dont check disposed of assets
    if a.disposed?
      return errors
    end

    # Strongly type the asset but only if we need to
    asset = a.is_typed? ? a : Asset.get_typed_asset a

    Rails.logger.debug "Testing asset #{asset.object_key} for compliance. Type is #{asset.class.name}"
    start_date = Chronic.parse('10/1/2015').to_date
    end_date = Chronic.parse('12/31/2015').to_date

    passed = true
    if asset.reported_condition_date.blank? or asset.reported_condition_date < start_date
      passed = false
      errors << "Condition has not been updated during the audit period"
    end

    if asset.service_status_date.blank? or asset.service_status_date < start_date
      passed = false
      errors << "Service Status has not been updated during the audit period"
    end

    if asset.respond_to? :milage_updates
      if asset.reported_mileage_date.blank? or asset.reported_mileage_date < start_date
        passed = false
        errors << "Mileage has not been updated during the audit period"
      end
    end

    audit = Audit.find_or_create_by(:organization_id => asset.organization_id, :auditable_id => asset.id, :auditable_type => asset.class.name, :activity_id => @context.id) do |aud|
      aud.audit_status_type_id = (passed == true) ? 2 : 3
      if errors.present?
        aud.notes = errors.join('\n')
      end
    end
    audit.save

  end

  def initialize(context)
    self.context = context
  end

  protected

end
