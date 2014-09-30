#------------------------------------------------------------------------------
#
# PolicyItem. 
#
# Masks TransamCore::PolicyItem. Adds:
#
#   :fuel_type
#   :replace_fuel_type
#   :max_service_life_miles
#   :extended_service_life_miles
#
#------------------------------------------------------------------------------
class PolicyItem < ActiveRecord::Base
  
  # Include the numeric sanitizers mixin
  include NumericSanitizers
  
  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------
  belongs_to  :policy
  belongs_to  :fuel_type
  belongs_to  :asset_subtype
  belongs_to  :replace_asset_subtype, :class_name => 'AssetSubtype', :foreign_key => :replace_asset_subtype_id
  belongs_to  :replace_fuel_type, :class_name => 'FuelType', :foreign_key => :replace_fuel_type_id

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates :policy,                  :presence => true
  validates :asset_subtype,           :presence => true
  validates :max_service_life_years,  :presence => true,  :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0}
  validates :max_service_life_miles,                      :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0}, :allow_nil => :true
  validates :replacement_cost,        :presence => true,  :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0}
  validates :pcnt_residual_value,     :presence => true,  :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100}
  validates :rehabilitation_cost,     :presence => true,  :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0}
  validates :extended_service_life_years,     :presence => true,  :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0}
  validates :extended_service_life_miles,     :presence => true,  :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0}
  validates :rehabilitation_year,     :presence => true,  :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0}, :allow_nil => :true
    
  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  default_scope { where(:active => true).order('asset_subtype_id ASC') }
  
  #------------------------------------------------------------------------------
  # List of hash parameters allowed by the controller
  #------------------------------------------------------------------------------
  FORM_PARAMS = [
    :policy_id,
    :asset_subtype_id, 
    :fuel_type_id,
    :max_service_life_years, 
    :max_service_life_miles, 
    :replacement_cost, 
    :rehabilitation_cost,
    :extended_service_life_years,
    :extended_service_life_miles,
    :pcnt_residual_value,
    :replacement_ali_code,
    :rehabilitation_ali_code,
    :rehabilitation_year,
    :replace_asset_subtype_id,
    :replace_fuel_type_id,
    :active    
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
    if fuel_type.blank?
      "#{asset_subtype}"
    else
      "#{asset_subtype}(#{fuel_type.code})"
    end
  end

  # Override setters to remove any extraneous formats from the number strings eg $, etc.      
  def max_service_life_years=(num)
    self[:max_service_life_years] = sanitize_to_int(num)
  end      
  def max_service_life_miles=(num)
    self[:max_service_life_miles] = sanitize_to_int(num)
  end      
  def replacement_cost=(num)
    self[:replacement_cost] = sanitize_to_int(num)
  end      
  def rehabilitation_cost=(num)
    self[:rehabilitation_cost] = sanitize_to_int(num)
  end      
  def extended_service_life_years=(num)
    self[:extended_service_life_years] = sanitize_to_int(num)
  end      
  def extended_service_life_miles=(num)
    self[:extended_service_life_miles] = sanitize_to_int(num)
  end      
  def pcnt_residual_value=(num)
    self[:pcnt_residual_value] = sanitize_to_int(num)
  end      
  
  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new policy
  def set_defaults
    self.max_service_life_years ||= 0
    self.max_service_life_miles ||= 0 
    self.replacement_cost ||= 0 
    self.extended_service_life_years ||= 0
    self.extended_service_life_miles ||= 0 
    self.rehabilitation_cost ||= 0 
    self.rehabilitation_year ||= 0
    self.active ||= true
  end    
        
end
