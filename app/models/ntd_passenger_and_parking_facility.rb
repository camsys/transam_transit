#------------------------------------------------------------------------------
#
# NTD Passenger and Parking Facility
#
# Represents a Passenger and Parking Facility Row in an NTD Form
#
#------------------------------------------------------------------------------
class NtdPassengerAndParkingFacility < ActiveRecord::Base

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
  # validates_inclusion_of :part_of_larger_facility, :in => [true, false]
  # validates :address1,                  :presence => true
  # validates :city,                      :presence => true
  # validates :state,                     :presence => true
  # validates :zip,                       :presence => true
  #
  # validates :longitude,                 :presence => true, :numericality => {:only_integer => true}
  # validates :latitude,                  :presence => true, :numericality => {:only_integer => true}
  #
  # validates :primary_mode,              :presence => true
  # validates :facility_type,             :presence => true
  # validates :year_built,                :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 1900}
  # validates :size,                      :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  # validates :size_type,                 :presence => true
  #
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
    :part_of_larger_facility,
    :address1,
    :city,
    :state,
    :zip,
    :latitude,
    :longiude,
    :primary_mode,
    :facility_type,
    :year_built,
    :size_sq_ft,
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
