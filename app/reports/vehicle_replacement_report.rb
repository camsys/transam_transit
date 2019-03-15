#------------------------------------------------------------------------------
#
# Vehicle Replacement Report
#
# Generates a report of vehicles that are scheduled to be replaced in a
# selected planning year
#
#------------------------------------------------------------------------------
class VehicleReplacementReport < AbstractAssetReport

  private
  def initialize(attributes={})
    @service = AssetEndOfServiceService.new
    super(attributes)
  end

  def get_assets(org_id_list, fiscal_year, asset_type_id=nil, asset_subtype_id=nil )
    Rails.logger.debug "AssetEndOfServiceService:  list()"
    #
    if org_id_list.blank?
      Rails.logger.warn "AssetEndOfServiceService:  disposition list: Org ID cannot be null"
      return []
    end

    # Start to set up the query
    conditions  = []
    values      = []

    # Filter for the selected org
    conditions << "transam_assets.organization_id IN (?)"
    values << org_id_list

    # Filter on Replacement Year    
    conditions << "transam_assets.scheduled_replacement_year = ?"
    values << fy_year

    category = FtaAssetCategory.find_by(name: 'Revenue Vehicles')
    TransitAsset.operational.where(fta_asset_category: category).where(conditions.join(' AND '), *values)
  end

  def set_defaults
    super
    if @fy_year
      @fy_year = @fy_year.to_i
    else
      @fy_year = current_planning_year_year
    end
  end

end
