#------------------------------------------------------------------------------
#
# Rail Car
#
# Implementation class for a RAIL CAR asset
#
#------------------------------------------------------------------------------
class RailCar < PassengerVehicle

  # Enable auditing of this model type. Only monitor uodate and destroy events
  has_paper_trail :on => [:update, :destroy]

  # Callbacks
  after_initialize :set_defaults

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_type_id => AssetType.find_by_class_name(self.name).id) }

  #------------------------------------------------------------------------------
  # Lists. These lists are used by derived classes to make up lists of attributes
  # that can be used for operations like full text search etc. Each derived class
  # can add their own fields to the list
  #------------------------------------------------------------------------------

  SEARCHABLE_FIELDS = [
  ]
  CLEANSABLE_FIELDS = [
  ]

  # List of hash parameters specific to this class that are allowed by the controller
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

  # Render the asset as a JSON object -- overrides the default json encoding
  def as_json(options={})
    super.merge({})
  end

  # Creates a duplicate that has all asset-specific attributes nilled
  def copy(cleanse = true)
    a = dup
    a.cleanse if cleanse
    vehicle_features.each do |x|
      a.vehicle_features << x
    end
    fta_service_types.each do |x|
      a.fta_service_types << x
    end
    fta_mode_types.each do |x|
      a.fta_mode_types << x
    end
    a
  end


  def searchable_fields
    a = super
    SEARCHABLE_FIELDS.each do |field|
      a << field
    end
    a
  end

  def cleansable_fields
    a = super
    CLEANSABLE_FIELDS.each do |field|
      a << field
    end
    a
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new raAil car
  def set_defaults
    super
    self.asset_type ||= AssetType.find_by_class_name(self.name)
  end

end
