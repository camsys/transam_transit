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
  has_many :agencies,             :class_name => "TransitOperators",  :foreign_key => "grantor_id"

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

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------
  
  # assets for a grantor are those assets that are owned by any member agencies
  def assets
    Asset.where('organization_id in (?)', [id])
  end
  
  
  #------------------------------------------------------------------------------
  # Overrides
  #------------------------------------------------------------------------------  
  def get_policy
    policies.current.first
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
  end    
  
end
      
