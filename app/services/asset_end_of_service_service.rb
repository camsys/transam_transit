#------------------------------------------------------------------------------
#
# AssetEndOfServiceService
#
# Contains business logic associated with managing the disposition of assets
#
#
#------------------------------------------------------------------------------
class AssetEndOfServiceService

  # Include the fiscal year mixin
  include FiscalYear

  #------------------------------------------------------------------------------
  #
  # Disposition List
  #
  # returns a list of assets that need to be disposed by FY, type, and subtype
  #
  #------------------------------------------------------------------------------

  def list(org_id_list, fy_year=current_planning_year_year, fta_asset_category_id=nil)

    Rails.logger.debug "AssetEndOfServiceService:  list()"
    #
    if org_id_list.blank?
      Rails.logger.warn "AssetEndOfServiceService:  disposition list: Org ID cannot be null"
      return []
    end

    # Start to set up the query
    conditions  = Hash.new

    # Filter for the selected org
    conditions[:organization_id] = org_id_list

    # Filter on Replacement Year
    conditions[:scheduled_replacement_year] = fy_year

    conditions[:fta_asset_category_id] = fta_asset_category_id unless fta_asset_category_id.nil?

    TransitAsset.operational.where(conditions)
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private

end
