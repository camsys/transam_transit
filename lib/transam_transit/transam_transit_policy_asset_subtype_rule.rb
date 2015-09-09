module TransamTransitPolicyAssetSubtypeRule
  #-----------------------------------------------------------------------------
  #
  # Extends TransamCore::PolicyItem
  #
  # Adds:
  #
  #   :fuel_type
  #   :replace_fuel_type
  #   :max_service_life_miles
  #   :extended_service_life_miles
  #
  #   Plus TEAM ALI codes
  #
  #-----------------------------------------------------------------------------
  extend ActiveSupport::Concern

  included do

    #---------------------------------------------------------------------------
    # Call Backs
    #---------------------------------------------------------------------------

    #---------------------------------------------------------------------------
    # Associations
    #---------------------------------------------------------------------------
    belongs_to  :fuel_type
    belongs_to  :replace_fuel_type, :class_name => 'FuelType', :foreign_key => :replace_fuel_type_id

    #---------------------------------------------------------------------------
    # Validations
    #---------------------------------------------------------------------------
    validates :min_service_life_miles,          :allow_nil => :true, :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0}
    validates :extended_service_life_miles,     :allow_nil => :true, :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0}

    # Add TEAM ALI codes
    validates :rehabilitation_code,        :presence => true,  :length => { :is => 8 }
    validates :engineering_design_code,    :allow_nil => true, :length => { :is => 8 }

    # Rolling stock -- road and rail
    validates :purchase_replacement_code,  :presence => true,  :length => { :is => 8 }
    validates :lease_replacement_code,     :allow_nil => true, :length => { :is => 8 }
    validates :purchase_expansion_code,    :allow_nil => true, :length => { :is => 8 }
    validates :lease_expansion_code,       :allow_nil => true, :length => { :is => 8 }

    # Facilities, Equipment
    validates :construction_code,          :allow_nil => true, :length => { :is => 8 }

    #---------------------------------------------------------------------------
    # List of hash parameters allowed by the controller
    #---------------------------------------------------------------------------
    FORM_PARAMS = [
      :fuel_type_id,
      :replace_fuel_type_id,
      :min_service_life_miles,
      :extended_service_life_miles,
      :engineering_design_code,
      :purchase_replacement_code,
      :lease_replacement_code,
      :purchase_expansion_code,
      :lease_expansion_code,
      :rehabilitation_code,
      :construction_code,
      :engineering_design_code
    ]

  end

  # ------------------------------------------------------
  #
  # Class Methods
  #
  # ------------------------------------------------------

  module ClassMethods

  end

  # ------------------------------------------------------
  #
  # Instance Methods
  #
  # ------------------------------------------------------

  # Override the to_s method
  def to_s
    if fuel_type.blank?
      "#{asset_subtype}"
    else
      "#{asset_subtype}(#{fuel_type.code})"
    end
  end

  # Sanitizers
  def min_service_life_miles=(num)
    self[:min_service_life_miles] = sanitize_to_int(num) unless num.blank?
  end
  def extended_service_life_miles=(num)
    self[:extended_service_life_miles] = sanitize_to_int(num) unless num.blank?
  end

  # Reuse purchase_replacement and lease_replacement for facility codes
  def purchase_code=(val)
    self[:purchase_replacement_code] = val
  end
  def purchase_code
    self.purchase_replacement_code
  end
  def lease_code=(val)
    self[:lease_replacement_code] = val
  end
  def lease_code
    self.lease_replacement_code
  end

end
