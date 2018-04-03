class TamPolicy < ActiveRecord::Base

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
    start_month_num = SystemConfig.instance.start_of_fiscal_year.split('-')[0].to_i
    "#{Date::MONTHNAMES[start_month_num]} - #{Date::MONTHNAMES[start_month_num == 1 ? 12 : start_month_num-1]}"
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
