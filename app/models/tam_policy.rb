class TamPolicy < ActiveRecord::Base

  has_paper_trail on: [:update]

  include TransamObjectKey

  include TransamFormatHelper

  # Callbacks
  after_initialize :set_defaults

  # anyone who had the privilege before no longer has the permissions in the new policy year
  after_create  { UsersRole.where(role_id: Role.find_by(name: 'tam_group_lead').id).delete_all }
  after_destroy { UsersRole.where(role_id: Role.find_by(name: 'tam_group_lead').id).delete_all }

  # Associations

  has_many    :tam_groups, :dependent => :destroy
  has_many    :tam_performance_metrics, :through => :tam_groups

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
    "#{format_as_fiscal_year(fy_year)} : #{period}"
  end

  def period
    start_months = Organization.distinct.pluck(:ntd_reporting_start_month)
    if start_months.count == 1
      "#{Date::MONTHNAMES[start_months[0]]} - #{Date::MONTHNAMES[start_months[0] == 1 ? 12 : start_months[0]-1]}"
    else
      "Multiple"
    end
  end

  def dup
    super.tap do |new_policy|
      self.tam_groups.where(organization_id: nil).each do |group|
        new_group = group.dup
        new_group.object_key = nil
        new_group.state = :inactive
        new_group.organizations = group.organizations

        new_policy.tam_groups << new_group
      end
    end
  end

  protected

  # Set resonable defaults for a new condition update event
  def set_defaults
    self.copied = self.copied.nil? ? false : self.copied
  end

end
