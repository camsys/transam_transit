#------------------------------------------------------------------------------
#
# NTD Service Vehicle Fleet
#
# Represents a Service Vehicle Fleet Row in an NTD Form
#
#------------------------------------------------------------------------------
class NtdServiceVehicleFleet < ActiveRecord::Base

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

  # validates :name,                      :presence => true
  # validates :vehicle_type,              :presence => true
  # validates :size,                      :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  # validates :avg_expected_years,        :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  # validates :manufacture_year,          :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 1900}
  # validates :pcnt_capital_responsibility,:presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100}
  # validates :estimated_cost,            :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  # validates :estimated_cost_year,       :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 1900}

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

    :name,
    :vehicle_type,
    :size,
    :avg_expected_years,
    :manufacture_year,
    :pcnt_capital_responsibility,
    :estimated_cost,
    :estimated_cost_year,

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

  end

end
