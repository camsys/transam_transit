#------------------------------------------------------------------------------
#
# FtaVehicle
#
# Abstract class that adds fta characteristics to a RollingStock asset
#
#------------------------------------------------------------------------------
class FtaVehicle < RollingStock

  # Callbacks
  after_initialize :set_defaults
  after_save       :require_at_least_one_fta_mode_type     # validate model for HABTM relationships
  after_save       :require_at_least_one_fta_service_type  # validate model for HABTM relationships

  # Clean up any HABTM associations before the asset is destroyed
  before_destroy { :clean_habtm_relationships }

  #------------------------------------------------------------------------------
  # Associations common to all fta vehicles
  #------------------------------------------------------------------------------

  # Each vehicle has a set (0 or more) of fta mode type
  has_and_belongs_to_many   :fta_mode_types,              :foreign_key => :asset_id

  # Each vehicle has a set (0 or more) of fta service type
  has_and_belongs_to_many   :fta_service_types,           :foreign_key => :asset_id

  # Each vehicle can have an fta ownership type
  belongs_to                :fta_ownership_type

  # Each vehicle has a single fta vehicle type
  belongs_to                :fta_vehicle_type

  validates                 :fta_ownership_type,       :presence => :true
  validates                 :fta_vehicle_type,         :presence => :true
  validates                 :gross_vehicle_weight,     :allow_nil => true, :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0}

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
    :fta_ownership_type_id,
    :fta_vehicle_type_id,
    :ada_accessible_lift,
    :ada_accessible_ramp,
    :fta_emergency_contingency_fleet,
    :fta_mode_type_ids => [],
    :fta_service_type_ids => []
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

  # returns true if this instance has a geometry that can be mapped, false
  # otherwise
  def mappable?
    ! geometry.nil?
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  def clean_habtm_relationships
    fta_mode_types.clear
    fta_service_types.clear
  end

  def require_at_least_one_fta_mode_type
    if fta_mode_types.count == 0
      errors.add(:fta_mode_types, "must be selected.")
      return false
    end
  end

  def require_at_least_one_fta_service_type
    if fta_service_types.count == 0
      errors.add(:fta_service_types, "must be selected.")
      return false
    end
  end

  # Set resonable defaults for a new fta vehicle
  def set_defaults
    super
    self.ada_accessible_lift ||= false
    self.ada_accessible_ramp ||= false
    self.fta_emergency_contingency_fleet ||= false
  end

end
