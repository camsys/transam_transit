#------------------------------------------------------------------------------
#
# NTD Service Vehicle Fleet
#
# Represents a Service Vehicle Fleet Row in an NTD Form
#
#------------------------------------------------------------------------------
class NtdRevenueVehicleFleet < ActiveRecord::Base

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------
  # Every row belongs to a NTD Form
  belongs_to  :ntd_form

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates :ntd_form,                  :presence => true

  # validates :rvi_id,                    :presence => true
  # validates :size,                      :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  # validates :num_active,                :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  # validates :num_ada_accessible,        :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  # validates :num_emergency_contingency, :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  #
  # validates :vehicle_type,              :presence => true
  # validates :funding_source,            :presence => true
  # validates :manufacture_year,          :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 1900}
  # validates :manufacture_code,          :presence => true
  # validates :model_number,              :presence => true
  #
  # validates :renewal_year,              :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  # validates :renewal_type,              :presence => true
  # validates :renewal_cost,              :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  # validates :renewal_cost_year,         :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  #
  # validates :replacement_cost,          :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  # validates :replacement_cost_year,     :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 1900}
  # validates_inclusion_of :replacement_cost_parts,     :in => [true, false]
  # validates_inclusion_of :replacement_cost_warranty,  :in => [true, false]
  #
  # validates :fuel_type,                 :presence => true
  # validates :vehicle_length,            :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  # validates :seating_capacity,          :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  # validates :standing_capacity,         :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  # validates :total_active_miles_in_period, :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  # validates :avg_lifetime_active_miles, :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------

  #------------------------------------------------------------------------------
  # Constants
  #------------------------------------------------------------------------------

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :id,
    :ntd_form_id,

    :rvi_id,
    :size,
    :num_active,
    :num_ada_accessible,
    :num_emergency_contingency,

    :renewal_year,
    :renewal_type,
    :renewal_cost,
    :renewal_cost_year,

    :fuel_type,
    :vehicle_length,
    :seating_capacity,
    :standing_capacity,
    :total_active_miles_in_period,
    :avg_lifetime_active_miles,

    :notes
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

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new form component
  def set_defaults
    self.useful_life_remaining ||= 0
  end

end
