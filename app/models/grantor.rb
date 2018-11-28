#------------------------------------------------------------------------------
#
# Grantor
#
# Represents an organization that manages transit operators
#
#------------------------------------------------------------------------------
class Grantor < FtaAgency

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------
  # Each grantor org has 0 or more transit agencies
  has_many :transit_operators,             :class_name => "TransitOperator",  :foreign_key => "grantor_id"

  # Each grantor org has 0 or more planning partners
  has_many :planning_partners,    :class_name => "PlanningPartner",   :foreign_key => "grantor_id"

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:organization_type_id => OrganizationType.find_by_class_name(self.name).id) }

  # List of allowable form param hash keys
  FORM_PARAMS = [
  ]

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  def self.createable?
    false # only one grantor is allowed in the system and must be setup in a new app
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  def updates_after_create
    return
  end

  # assets for a grantor are those assets that are owned by any member agencies
  def assets
    Rails.application.config.asset_base_class_name.constantize.where(organization_id: id)
  end


  #------------------------------------------------------------------------------
  # Overrides
  #------------------------------------------------------------------------------
  def get_policy
    policies.active.first
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new grantor
  def set_defaults
    super
    self.organization_type ||= OrganizationType.find_by_class_name(self.name).first
    self.license_holder = self.license_holder.nil? ? true : self.license_holder
  end

end
