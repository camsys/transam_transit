#------------------------------------------------------------------------------
#
# GrantPurchase
#
# Tracks asset purchases against specific grants. Each purchase tracks the percentage
# of the asset cost against the grant.
#
#------------------------------------------------------------------------------
class GrantPurchase < ActiveRecord::Base
                
  # Include the fiscal year mixin
  include FiscalYear
  
  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize                  :set_defaults

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------
  # Every grant purchase is associated with an asset and a grant
  belongs_to  :grant
  belongs_to  :asset

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates :grant,                    :presence => true
  validates :asset,                    :presence => true
  validates :pcnt_purchase_cost,       :presence => true, :numericality => {:only_integer => :true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100}

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  
  # default scope

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :asset_id,
    :grant_id,
    :pcnt_purchase_cost
  ]
  
  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------
    
  def self.allowable_params
    FORM_PARAMS
  end
  
  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------
      
  def to_s
    name
  end
  
  def name
    grant.blank? ? '' : "#{grant}: #{pcnt_purchase_cost}%"
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected 

  # Set resonable defaults for a new capital project
  def set_defaults
    
    self.pcnt_purchase_cost ||= 80
        
  end    
      
end
