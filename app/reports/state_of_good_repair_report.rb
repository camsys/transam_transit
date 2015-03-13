#------------------------------------------------------------------------------
#
# State of Good Repair Report
#
# Generates a report of assets representing the CURRENT state of an agency's
# assets
#
#------------------------------------------------------------------------------
class StateOfGoodRepairReport < AbstractAssetReport

  private
  def initialize(attributes={})
    # No Service for this report, unlike other AssetReports.  ALL assets under review
    # @service = ####
    super(attributes)
  end

  # Override standard method (via service), get all undisposed assets
  def get_assets(organization_id_list, fiscal_year, asset_type_id=nil, asset_subtype_id=nil )
    Asset.undisposed.where(organization_id: organization_id_list)
  end

  def set_defaults
    if @fy_year
      @fy_year = @fy_year.to_i
    else 
      @fy_year = current_fiscal_year_year
    end
  end
end
