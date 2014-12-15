#------------------------------------------------------------------------------
#
# PurchaseHistoryLoader
#
# Generic class for processing purchase history for an asset
#
#------------------------------------------------------------------------------
class PurchaseHistoryLoader < InventoryLoader
  
  PURCHASE_COST_COL = 0
  PURCHASE_DATE_COL = 1
  PURCHASED_NEW_COL = 2
  SELLER_NAME_COL   = 3
  USEFUL_LIFE_COL   = 4
  USEFUL_MILES_COL  = 5
  NOTES_COL         = 6
    
  def process(asset, cells)
               
    # Purchase Cost
    asset.purchase_cost = as_integer(cells[PURCHASE_COST_COL])
    
    # Purchase Date
    purchase_date = as_date(cells[PURCHASE_DATE_COL])
    asset.purchase_date = purchase_date 

    # Purchased New
    asset.purchased_new = as_boolean(cells[PURCHASE_COST_COL])

    # Asset Seller
    #asset.seller = wb.cell(r, @seller)
    
    # Expected Useful Life (Years)
    asset.expected_useful_life = as_integer(cells[USEFUL_LIFE_COL])
    if asset.expected_useful_life == 0
      @warnings << "Useful life years not set. Defaulting to policy useful life."
      asset.expected_useful_life = asset.policy_rule.max_service_life_years
    end

    # Expected Useful Life (Miles)
    asset.expected_useful_miles = as_integer(cells[USEFUL_MILES_COL])
    if asset.expected_useful_miles == 0
      @warnings << "Useful life miles not set. Defaulting to policy useful life."
      asset.expected_useful_miles = asset.policy_rule.max_service_life_miles
    end

    # Purchase Notes
    note_text = as_string(cells[NOTES_COL])
    unless note_text.blank?
      comment = Comment.new
      comment.comment = note_text
      comment.creator = asset.creator
      @comments << comment            
    end
    
  end
  
  private
  def initialize
    super
  end
  
end