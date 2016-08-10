#------------------------------------------------------------------------------
#
# FtaVehicle
#
# Abstract class that adds fta characteristics to a RollingStock asset
#
#------------------------------------------------------------------------------
class FtaVehicle < RollingStock

  HUMANIZED_ATTRIBUTES = {
      :serial_number => "VIN"
  }

  def self.human_attribute_name(attr, options = {})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

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

  # Each vehicle can have an fta bus mode type
  belongs_to                :fta_bus_mode_type

  validates                 :fta_ownership_type,       :presence => :true
  validates                 :fta_vehicle_type,         :presence => :true
  validates                 :gross_vehicle_weight,     :allow_nil => true, :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0}

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    [
      :fta_ownership_type_id,
      :fta_vehicle_type_id,
      :ada_accessible_lift,
      :ada_accessible_ramp,
      :fta_emergency_contingency_fleet,
      :fta_bus_mode_type_id,
      :fta_mode_type_ids => [],
      :fta_service_type_ids => []
    ]
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
      :fta_ownership_type_id => self.fta_ownership_type.present? ? self.fta_ownership_type.to_s : nil,
      :fta_vehicle_type_id => self.fta_vehicle_type.present? ? self.fta_vehicle_type.to_s : nil,
      :fta_bus_mode_type_id => self.fta_bus_mode_type.present? ? self.fta_bus_mode_type.to_s : nil,
      :ada_accessible_lift => self.ada_accessible_lift,
      :ada_accessible_ramp => self.ada_accessible_ramp,
      :fta_mode_types => self.fta_mode_types,
      :fta_service_types => self.fta_service_types
    })
  end

  def searchable_fields
    a = []
    a << super
    a += [:fta_vehicle_type, :fta_bus_mode_type]
    a.flatten
  end

  # returns true if this instance has a geometry that can be mapped, false
  # otherwise
  def mappable?
    ! geometry.nil?
  end

  # Returns true if the vehicle is ada accessible via either a lift or ramp
  def ada_accessible?
    if ada_accessible_ramp == true or  ada_accessible_lift == true
      true
    else
      false
    end
  end

  def fta_bus?
    fta_mode_types_contain_bus = false
    fta_mode_types.map do |fta_mode_type|
      fta_mode_types_contain_bus = true if fta_mode_type.name == 'Bus'
    end
    fta_mode_types_contain_bus
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
    self.fta_emergency_contingency_fleet ||= false
  end

end
