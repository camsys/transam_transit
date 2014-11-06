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

  # Every transit agency has one or more service types
  has_and_belongs_to_many  :service_types, :foreign_key => 'organization_id'

  # Every transit agency belongs to a governing body type
  belongs_to :governing_body_type

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------

  # List of allowable form param hash keys
  FORM_PARAMS = [
    :service_type_ids => []
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

  # Short cuts for determining the sevice types
  def service_type_urban?
    type = ServiceType.find_by_name('Urban')
    service_types.include? type
  end
  def service_type_rural?
    type = ServiceType.find_by_name('Rural')
    service_types.include? type
  end
  def service_type_shared_ride?
    type = ServiceType.find_by_name('Shared Ride')
    service_types.include? type
  end
  def service_type_intercity_bus?
    type = ServiceType.find_by_name('Intercity Bus')
    service_types.include? type
  end
  def service_type_intercity_rail?
    type = ServiceType.find_by_name('Intercity Rail')
    service_types.include? type
  end
  def service_type_5310?
    type = ServiceType.find_by_name('5310')
    service_types.include? type
  end

  # Dependent on inventory
  def has_assets?
    assets.count > 0
  end

  # returns the count of assets of the given type. If no type is selected it returns the total
  # number of assets
  def asset_count(conditions = [], values = [])
    conditions.empty? ? assets.count : assets.where(conditions.join(' AND '), *values).count
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
