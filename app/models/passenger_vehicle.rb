#------------------------------------------------------------------------------
#
# PassengerVehicle
#
# Abstract class that adds passenger characteristics to a Vehicle
#
#------------------------------------------------------------------------------
class PassengerVehicle < FtaVehicle

  # Callbacks
  after_initialize :set_defaults

  # Clean up any HABTM associations before the asset is destroyed
  before_destroy { :clean_habtm_relationships }

  # Clean up any HABTM associations before the asset is destroyed
  before_destroy { vehicle_features.clear }

  #------------------------------------------------------------------------------
  # Associations common to all passenger vehicles
  #------------------------------------------------------------------------------

  # Each vehicle has a set (0 or more) of vehicle features
  has_and_belongs_to_many   :vehicle_features,    :foreign_key => 'asset_id'

  # ----------------------------------------------------
  # Vehicle Physical Characteristics
  # ----------------------------------------------------
  validates :seating_capacity,    :presence => :true, :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0}
  validates :standing_capacity,   :presence => :true, :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0}
  validates :wheelchair_capacity, :presence => :true, :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0}
  validates :vehicle_length,      :presence => :true, :numericality => {:only_integer => :true, :greater_than => 0}

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
    :seating_capacity,
    :standing_capacity,
    :wheelchair_capacity,
    :vehicle_length,
    :vehicle_feature_ids => []
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
    super.merge(
    {
      :seating_capacity => self.seating_capacity,
      :standing_capacity => self.standing_capacity,
      :wheelchair_capacity => self.wheelchair_capacity,
      :vehicle_length => self.vehicle_length,
      :vehicle_features => self.vehicle_features
    })
  end

  # Override setters to remove any extraneous formats from the number strings eg $, etc.
  def seating_capacity=(num)
    self[:seating_capacity] = sanitize_to_int(num)
  end
  def standing_capacity=(num)
    self[:standing_capacity] = sanitize_to_int(num)
  end
  def wheelchair_capacity=(num)
    self[:wheelchair_capacity] = sanitize_to_int(num)
  end
  def vehicle_length=(num)
    self[:vehicle_length] = sanitize_to_int(num)
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
    a = []
    a << super
    SEARCHABLE_FIELDS.each do |field|
      a << field
    end
    a.flatten
  end

  def cleansable_fields
    a = []
    a << super
    CLEANSABLE_FIELDS.each do |field|
      a << field
    end
    a.flatten
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  def clean_habtm_relationships
    vehicle_features.clear
  end

  # Set resonable defaults for a new generic sign
  def set_defaults
    super
    self.seating_capacity ||= 0
    self.standing_capacity ||= 0
    self.wheelchair_capacity ||= 0
  end

end
