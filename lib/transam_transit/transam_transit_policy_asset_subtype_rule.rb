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
    validates :rehabilitation,        :presence => true,  :length => { :is => 8 }
    validates :engineering_design,    :allow_nil => true, :length => { :is => 8 }

    # Rolling stock -- road and rail
    validates :purchase_replacement,  :presence => true,  :length => { :is => 8 }
    validates :lease_replacement,     :allow_nil => true, :length => { :is => 8 }
    validates :purchase_expansion,    :allow_nil => true, :length => { :is => 8 }
    validates :lease_expansion,       :allow_nil => true, :length => { :is => 8 }

    # Facilities, Equipment
    validates :construction,          :allow_nil => true, :length => { :is => 8 }
    validates :engineering_design,    :allow_nil => true, :length => { :is => 8 }

    #---------------------------------------------------------------------------
    # List of hash parameters allowed by the controller
    #---------------------------------------------------------------------------
    FORM_PARAMS = [
      :fuel_type_id,
      :replace_fuel_type_id,
      :min_service_life_miles,
      :extended_service_life_miles,
      :engineering_design,
      :purchase_replacement,
      :lease_replacement,
      :purchase_expansion,
      :lease_expansion,
      :rehabilitation,
      :construction,
      :engineering_design
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
  def purchase=(val)
    self[:purchase_replacement] = val
  end
  def purchase
    self.purchase_replacement
  end
  def lease=(val)
    self[:lease_replacement] = val
  end
  def lease
    self.lease_replacement
  end

end
