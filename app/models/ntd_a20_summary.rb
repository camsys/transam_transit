class NtdA20Summary < ApplicationRecord
  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------
  belongs_to  :ntd_report
  belongs_to  :fta_mode_type
  belongs_to  :fta_service_type

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates :ntd_report,                  :presence => true

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
      :ntd_report_id,
      :fta_mode_id,
      :fta_service_type_id,
      :monthly_total_average_restrictions_length
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
    "NTDA20Summary"
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

end
