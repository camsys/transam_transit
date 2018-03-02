class TamPolicy < ActiveRecord::Base

  include TransamObjectKey

  include TransamFormatHelper

  # Callbacks
  after_initialize :set_defaults

  # Associations

  has_many    :tam_groups, :dependent => :destroy

  # Validations
  validates :fy_year, :presence => true

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { order(fy_year: :desc) }

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

  def to_s
    "#{format_as_fiscal_year(fy_year+1)}: #{period}"
  end

  def period
    start_month_num = SystemConfig.instance.start_of_fiscal_year.split('-')[0].to_i
    "#{Date::MONTHNAMES[start_month_num]} - #{Date::MONTHNAMES[start_month_num == 1 ? 12 : start_month_num-1]}"
  end

  protected

  # Set resonable defaults for a new condition update event
  def set_defaults
    self.copied = self.copied.nil? ? false: self.copied
  end

end
