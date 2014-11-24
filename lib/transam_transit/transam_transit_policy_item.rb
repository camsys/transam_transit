module TransamTransit
  module TransamTransitPolicyItem
    #------------------------------------------------------------------------------
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
    #------------------------------------------------------------------------------
    extend ActiveSupport::Concern
  
    included do
  
      # ----------------------------------------------------
      # Call Backs
      # ----------------------------------------------------
  
      # ----------------------------------------------------
      # Associations
      # ----------------------------------------------------
      belongs_to  :fuel_type
      belongs_to  :replace_fuel_type, :class_name => 'FuelType', :foreign_key => :replace_fuel_type_id
  
      # ----------------------------------------------------
      # Validations
      # ----------------------------------------------------
      validates :max_service_life_miles,          :allow_nil => :true, :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0} 
      validates :extended_service_life_miles,     :allow_nil => :true, :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0}
  
      # ----------------------------------------------------
      # List of hash parameters allowed by the controller
      # ----------------------------------------------------
      FORM_PARAMS = [
        :fuel_type_id,
        :replace_fuel_type_id, 
        :max_service_life_miles,
        :extended_service_life_miles 
      ]

    end
  
    # ------------------------------------------------------
    #
    # Class Methods
    #
    # ------------------------------------------------------
  
    module ClassMethods

      def self.allowable_params
        
        FORM_PARAMS
      end
  
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
    def max_service_life_miles=(num)
      self[:max_service_life_miles] = sanitize_to_int(num) unless num.blank?
    end      
    def extended_service_life_miles=(num)
      self[:extended_service_life_miles] = sanitize_to_int(num) unless num.blank?
    end      
    
  end
end
