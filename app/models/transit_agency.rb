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
  has_many :assets,   :foreign_key => 'organization_id', :class_name => Rails.application.config.asset_base_class_name

  # every transit agency can have 0 or more policies
  has_many :policies, :foreign_key => 'organization_id'

  has_many  :archived_fiscal_years, :foreign_key => 'organization_id'

  has_many :rta_org_credentials, dependent: :destroy, :foreign_key => 'organization_id'
  accepts_nested_attributes_for :rta_org_credentials

  # Every transit agency belongs to a governing body type
  belongs_to :governing_body_type


  # Validation for legal name is only necessary for transit organizations
  validates :legal_name,         :presence => true

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------

  # List of allowable form param hash keys
  FORM_PARAMS = [
    :governing_body_type_id,
    :governing_body,
    :rta_org_credentials_attributes => [RtaOrgCredential.allowable_params]
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
  
  def group_lead_candidates
    planning_partner_type_id = OrganizationType.find_by(class_name: "PlanningPartner").id

    users.with_any_role(:transit_manager, :manager) + users.includes(:organization).with_role(:guest).where(organizations: {organization_type_id: planning_partner_type_id})
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
