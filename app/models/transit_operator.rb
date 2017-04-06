#------------------------------------------------------------------------------
#
# TransitOperator
#
# Represents an transit operator in TransAM Transit
#
#------------------------------------------------------------------------------
class TransitOperator < FtaAgency

  # Include the fiscal year mixin
  include FiscalYear

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize :set_defaults

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------

  # Each Transit Operator has a single Grantor organization
  belongs_to  :grantor,           :class_name => "Grantor",               :foreign_key => "grantor_id"

  # Every Transit Operator has one or more service provider types
  has_and_belongs_to_many  :service_provider_types, :foreign_key => 'organization_id'

  # Each Transit Operator has a single Planning Organization
  belongs_to  :planning_partner,  :class_name => "PlanningPartner",  :foreign_key => "planning_partner_id"

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:organization_type_id => OrganizationType.find_by_class_name(self.name).id) }

  # List of allowable form param hash keys
  FORM_PARAMS = [
    :grantor_id,
    :planning_partner_id,
    :service_provider_type_ids => []
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
    true
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------
  # Short cuts for determining the sevice types

  def updates_after_create
    parent_policy = Policy.where('parent_id IS NULL').first
    agency_policy = parent_policy.dup
    agency_policy.organization = self
    agency_policy.parent_id = parent_policy.id
    agency_policy.description = "#{self.short_name} Transit Policy"
    agency_policy.save!
  end

  def service_type_urban?
    type = ServiceProviderType.find_by_name('Urban')
    service_provider_types.include? type
  end
  def service_type_rural?
    type = ServiceProviderType.find_by_name('Rural')
    service_provider_types.include? type
  end
  def service_type_shared_ride?
    type = ServiceProviderType.find_by_name('Shared Ride')
    service_provider_types.include? type
  end
  def service_type_intercity_bus?
    type = ServiceProviderType.find_by_name('Intercity Bus')
    service_provider_types.include? type
  end
  def service_type_intercity_rail?
    type = ServiceProviderType.find_by_name('Intercity Rail')
    service_provider_types.include? type
  end

  #------------------------------------------------------------------------------
  # Overrides
  #------------------------------------------------------------------------------

  def get_policy
    unless policies.empty?
      # get the current policy if one has been created and set as current
      policy = policies.active.first
    end
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
    self.organization_type ||= OrganizationType.find_by_class_name(self.name).first
    self.license_holder = self.license_holder.nil? ? false : self.license_holder
  end

end
