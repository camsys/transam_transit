#------------------------------------------------------------------------------
#
# PolicyRuleService
#
# Attempts to find the policy rule that best matches an asset.
#
# Masks the TransAM:Core::PolicyRuleService class
#
# The service returns a single policy rule or nil if no matching policy rule is
# found.
#
#------------------------------------------------------------------------------
class PolicyRuleService

  #------------------------------------------------------------------------------
  #
  # Match
  #
  # Single entry point. User passes in a policy and an asset.
  #
  #------------------------------------------------------------------------------
  def match(policy, asset)

    if policy.nil?
      Rails.logger.info "policy cannot be nil."
      return
    end
    if asset.nil?
      Rails.logger.info "asset cannot be nil."
      return
    end

    p = policy
    # make sure the asset is typed
    a = asset.is_typed? ? asset : Asset.get_typed_asset(asset)

    # Check the rules for this policy and its parents. This first pass checks for the
    # typed version of the asset and performs a detailed check
    p = policy
    while p
      rule = evaluate(p, a, true)
      if rule
        break
      else
        # Check the policies parent if it has one
        p = p.parent
      end
    end

    # If the rule has not been matched, try it again as a generic asset that will only
    # match on asset subtype
    if rule.nil?
      p = policy
      while p
        rule = evaluate(p, a, false)
        if rule
          break
        else
          # Check the policies parent if it has one
          p = p.parent
        end
      end
    end
    # return whatever we find
    rule
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Perform the actual logic for matching a policy item to an asset.
  def evaluate(policy, asset, use_detailed = false)

    # If the asset has a fuel type, then check for fuel type matches
    if use_detailed and asset.respond_to? :fuel_type and ! asset.fuel_type.blank?
      policy.policy_items.where('asset_subtype_id = ? AND fuel_type_id = ?', asset.asset_subtype_id, asset.fuel_type_id).first
    else
      policy.policy_items.where('asset_subtype_id = ?', asset.asset_subtype_id).first
    end
  end

  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private
  
end
