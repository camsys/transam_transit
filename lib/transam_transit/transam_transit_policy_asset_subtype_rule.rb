module TransamTransitPolicyAssetSubtypeRule
  #-----------------------------------------------------------------------------
  #
  # Extends TransamCore::PolicyAssetSubtypeRule
  #
  # Adds:
  #
  #   :fuel_type
  #   :replace_fuel_type
  #   :min_service_life_miles
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
    validate  :validate_min_allowable_mileages

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

    validate :unique_by_subtype_and_fuel_type

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
      :construction_code
    ]

  end

  #-----------------------------------------------------------------------------
  # Class Methods
  #-----------------------------------------------------------------------------
  module ClassMethods

  end

  #-----------------------------------------------------------------------------
  # Instance Methods
  #-----------------------------------------------------------------------------

  # Override the to_s method
  def to_s
    if fuel_type.blank?
      "#{asset_subtype}"
    else
      "#{asset_subtype}(#{fuel_type.code})"
    end
  end

  def can_destroy?
    if !self.default_rule
      true # any rule not being used can be destroyed
    else
      # check there are no assets of that subtype/fuel type or isnt a rule for a replace with
      Asset.where(organization_id: self.policy.organization_id, asset_subtype_id: self.asset_subtype_id, fuel_type_id: self.fuel_type_id).count == 0 && PolicyAssetSubtypeRule.where(policy_id: self.policy_id, replace_asset_subtype_id: self.asset_subtype_id, replace_fuel_type_id: self.fuel_type_id).count == 0
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

  def min_allowable_mileages(subtype=nil)
    subtype = self.asset_subtype if subtype.nil?
    # This method gets the min values for child orgs that are not less than the value
    # set by the parent org
    results = Hash.new

    if policy.present? and policy.parent.present?
      attributes_to_compare = [
        :min_service_life_miles,
        :extended_service_life_miles
      ]

      parent_rule = policy.parent.policy_asset_subtype_rules.find_by(asset_subtype: subtype)
      if parent_rule.present?
        attributes_to_compare.each do |attr|

          results[attr] = parent_rule.send(attr)
        end
      end
    end
    results
  end

  #-----------------------------------------------------------------------------
  protected
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  private
  #-----------------------------------------------------------------------------
  def validate_min_allowable_mileages
    # This method validates that values for child orgs are not less than the value
    # set by the parent org

    # Only test vehicle types
    unless ["Vehicle", "SupportVehicle"].include? asset_subtype.asset_type.class_name
      return true
    end

    return_value = true

    min_allowable_mileages.each do |attr, val|
      # Make sure we don't try to test nil values. Other validations should
      # take care of these
      if self.send(attr).blank?
        next
      end

      if self.send(attr) < val
        errors.add(attr, "cannot be less than #{val}, which is the minimum set by #{ policy.parent.organization.short_name}'s policy")
        return_value = false
      end
    end

    return_value
  end

  def unique_by_subtype_and_fuel_type
    return_value = true

    if self.policy.policy_asset_subtype_rules.where(asset_subtype: self.asset_subtype, fuel_type: self.fuel_type).count > 1
      errors.add(:fuel_type, "must be unique to subtype")
      return_value = false
    end

    return_value
  end

end
