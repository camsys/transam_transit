class NtdInfrastructure < ApplicationRecord
  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------
  # Every row belongs to a NTD Form
  belongs_to  :ntd_report

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates :ntd_report,                  :presence => true

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------

  #------------------------------------------------------------------------------
  # Constants
  #------------------------------------------------------------------------------

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :ntd_report_id,
    :fta_mode,
    :fta_service_type,
    :fta_type,
    :size,
    :linear_miles,
    :track_miles,
    :expected_service_life,
    :pcnt_capital_responsibility,
    :shared_capital_responsibility_organization,
    :description,
    :notes,
    :allociation_unit,
    :pre_nineteen_thirty,
    :nineteen_thirty,
    :nineteen_forty,
    :nineteen_fifty,
    :nineteen_sixty,
    :nineteen_seventy,
    :nineteen_eighty,
    :nineteen_ninety,
    :two_thousand,
    :two_thousand_ten,
    :two_thousand_twenty
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
    "#{fta_mode} #{fta_service_type}"
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
