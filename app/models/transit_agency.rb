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
