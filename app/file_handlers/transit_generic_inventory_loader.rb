#------------------------------------------------------------------------------
#
# GenericVehicleInventoryLoader
#
# Class for loading generic vehicle assets.
#
#------------------------------------------------------------------------------
class TransitGenericInventoryLoader < RollingStockLoader

  PURCHASE_COST_COL         = 0
  FTA_FUNDING_TYPE_COL      = 1

  def process(asset, cells)

    # Manufacturer Model
    asset.purchase_cost = as_string(cells[PURCHASE_COST_COL])
    @errors << "Purchase cost not supplied." if asset.purchase_cost.blank?

    # FTA Funding Type -- check both name and code
    fta_funding_type_str = as_string(cells[FTA_FUNDING_TYPE_COL])
    fta_funding_type = FtaFundingType.search(fta_funding_type_str)
    if fta_funding_type_str.nil?
      fta_funding_type = FtaFundingType.find_by_name("Unknown")
      @warnings << "Fta Funding Type '#{fta_funding_type_str}' not found. Defaulting to 'Unknown'."
    end
    asset.fta_funding_type = fta_funding_type

    # default service life
    policy_analyzer = asset.policy_analyzer
    asset.expected_useful_life = policy_analyzer.get_min_service_life_months
    asset.expected_useful_miles = policy_analyzer.get_min_service_life_miles

  end

  private
  def initialize
    super
  end

end
