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
  has_and_belongs_to_many :planning_partners, :class_name => "PlanningPartner", :join_table => 'planning_partners_organizations', :foreign_key => "organization_id"

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:organization_type_id => OrganizationType.find_by_class_name(self.name).id) }

  # List of allowable form param hash keys
  FORM_PARAMS = [
    :grantor_id,
    :planning_partner_id,
    :service_provider_type_ids => [],
    :planning_partnter_ids => []
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
    agency_policy.object_key = nil
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

  def tam_group(year=nil)
    group = nil

    (year.nil? ? TamPolicy.all : TamPolicy.where(fy_year: year)).each do |policy|
      group = policy.tam_groups.includes(:organizations).where(organizations: {id: self.id}, parent_id: nil).first
      break if group.present?
    end

    group.reload # have to reload it so it uses .find by id so the join to organizations doesn't mess other calls to the group instance
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
