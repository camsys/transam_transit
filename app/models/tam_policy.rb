class TamPolicy < ActiveRecord::Base

  include TransamObjectKey

  # Callbacks
  after_initialize :set_defaults

  # Associations

  has_many    :tam_groups

  # Validations


  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope {  }

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :fy_year,
    :copied
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


  protected

  # Set resonable defaults for a new condition update event
  def set_defaults
    self.copied = self.copied.nil? ? false: self.copied
  end

end
