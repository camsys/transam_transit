#------------------------------------------------------------------------------
#
# Transit Agency
#
# Represents a basic organization that has transit assets
#
#------------------------------------------------------------------------------
class TransitAgency < Organization

  # Include the fiscal year mixin
  include FiscalYear

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize :set_defaults

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------

  # every transit agency can own assets
  has_many :assets,   :foreign_key => 'organization_id'

  # every transit agency can have 0 or more policies
  has_many :policies, :foreign_key => 'organization_id'

  has_many  :archived_fiscal_years, :foreign_key => 'organization_id'

  # Every transit agency belongs to a governing body type
  belongs_to :governing_body_type

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------

  # List of allowable form param hash keys
  FORM_PARAMS = [
    :governing_body_type_id,
    :governing_body
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

  # Dependent on inventory
  def has_assets?
    assets.count > 0
  end

  # returns the count of assets of the given type. If no type is selected it returns the total
  # number of assets
  def asset_count(conditions = [], values = [])
    conditions.empty? ? assets.count : assets.where(conditions.join(' AND '), *values).count
  end

  def last_archived_fiscal_year
    # force it so that if there are no archived years can only go as far back as the num forecast years
    archived_fiscal_years.order(:fy_year).last.try(:fy_year) || (current_fiscal_year_year - SystemConfig.instance.num_forecasting_years)
  end

  def first_archivable_fiscal_year
    last_archived_fiscal_year + 1
  end

  def has_group_lead_candidate?
    planning_partner_type_id = OrganizationType.find_by(class_name: "PlanningPartner").id

    users.with_role(:manager).exists? ||
      users.with_role(:transit_manager).exists? ||
      users.with_role(:guest).includes(:organization).any?{|u| (u.organization.organization_type_id == planning_partner_type_id)}
  end
  
  def group_lead_candidates
    planning_partner_type_id = OrganizationType.find_by(class_name: "PlanningPartner").id

    users.includes(:organization).with_any_role(:transit_manager, :manager, :guest)
      .select{|u| (!u.has_role?(:guest) ||
                   u.organization.organization_type_id == planning_partner_type_id)}
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new organization
  def set_defaults
    super
  end

end
