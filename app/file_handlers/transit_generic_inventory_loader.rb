#------------------------------------------------------------------------------
#
# GenericVehicleInventoryLoader
#
# Class for loading generic vehicle assets.
#
#------------------------------------------------------------------------------
class TransitGenericInventoryLoader < RollingStockLoader

  PURCHASED_NEW_COL       = 0
  PURCHASE_COST_COL       = 1
  PURCHASE_DATE_COL       = 2
  IN_SERVICE_DATE_COL     = 3
  FTA_FUNDING_TYPE_COL    = 4

  def process(asset, cells)

    # Purchased New
    purchased_new = as_string(cells[PURCHASED_NEW_COL])
    if purchased_new == 'YES'
      asset.purchased_new = true
    elsif purchased_new == 'NO'
      asset.purchased_new = false
    else
      @warnings << "Purchased new not supplied."
    end

    # Purchase Cost
    asset.purchase_cost = as_string(cells[PURCHASE_COST_COL])
    @warnings << "Purchase cost not supplied." if asset.purchase_cost.blank?

    # Purchase Date
    purchase_date = as_date(cells[PURCHASE_DATE_COL])
    if purchase_date.blank?
      @warnings << "Purchase date not supplied."
    else
      asset.purchase_date = purchase_date
    end

    # In Service Date
    in_service_date = as_date(cells[IN_SERVICE_DATE_COL])
    if in_service_date.blank?
      @warnings << "In service date not supplied."
    else
      asset.in_service_date = in_service_date
    end

    # FTA Funding Type -- check both name and code
    fta_funding_type = FtaFundingType.search(as_string(cells[FTA_FUNDING_TYPE_COL]))
    if fta_funding_type.nil?
      @warnings << "Fta Funding Type not found."
    else
      asset.fta_funding_type = fta_funding_type
    end

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
