# --------------------------------
# # DEPRECATED see TTPLAT-1832 or https://wiki.camsys.com/pages/viewpage.action?pageId=51183790
# --------------------------------

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

  # Clean up any HABTM associations before the asset is destroyed
  before_destroy { :clean_habtm_relationships }

  #------------------------------------------------------------------------------
  # Associations common to all fta vehicles
  #------------------------------------------------------------------------------

  # Each vehicle has a set (0 or more) of fta mode type
  has_many                  :assets_fta_mode_types,       :foreign_key => :asset_id
  has_and_belongs_to_many   :fta_mode_types,              :foreign_key => :asset_id

  # These associations support the separation of mode types into primary and secondary.
  has_one :primary_assets_fta_mode_type, -> { is_primary },
          class_name: 'AssetsFtaModeType', :foreign_key => :asset_id
  has_one :primary_fta_mode_type, through: :primary_assets_fta_mode_type, source: :fta_mode_type
  
  # Each vehicle has a set (0 or more) of fta service type
  has_many                  :assets_fta_service_types,       :foreign_key => :asset_id
  has_and_belongs_to_many   :fta_service_types,           :foreign_key => :asset_id

  # These associations support the separation of service types into primary and secondary.
  has_one :primary_assets_fta_service_type, -> { is_primary },
          class_name: 'AssetsFtaServiceType', :foreign_key => :asset_id
  has_one :primary_fta_service_type, through: :primary_assets_fta_service_type, source: :fta_service_type

  # Each vehicle can have an fta ownership type
  belongs_to                :fta_ownership_type

  # Each vehicle can have an fta bus mode type
  belongs_to                :fta_bus_mode_type

  validates                 :fta_ownership_type,       :presence => true
  validates                 :gross_vehicle_weight,     :allow_nil => true, :numericality => {:only_integer => true,   :greater_than_or_equal_to => 0}
  #validates                 :primary_fta_mode_type_id,    :presence => true
  #validates                 :primary_fta_service_type_id, :presence => true
  validates :pcnt_capital_responsibility, :allow_nil => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100}

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    [
      :fta_ownership_type_id,
      :other_fta_ownership_type,
      :ada_accessible_lift,
      :ada_accessible_ramp,
      :fta_emergency_contingency_fleet,
      :fta_bus_mode_type_id,
      :primary_fta_mode_type_id,
      :primary_fta_service_type_id,
      :pcnt_capital_responsibility
    ]
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  def fta_type
    FtaSupportVehicleType.find_by(id: fta_support_vehicle_type_id) || FtaVehicleType.find_by(id: fta_vehicle_type_id)
  end
  def fta_type_id
    fta_support_vehicle_type_id || fta_vehicle_type_id
  end

  def primary_fta_mode_type_id
    primary_fta_mode_type.try(:id)
  end

  # Override setters for primary_fta_mode_type for HABTM association
  def primary_fta_mode_type_id=(num)
    build_primary_assets_fta_mode_type(fta_mode_type_id: num, is_primary: true)
  end

  def primary_fta_service_type_id
    primary_fta_service_type.try(:id)
  end

  # Override setters for primary_fta_mode_type for HABTM association
  def primary_fta_service_type_id=(num)
    build_primary_assets_fta_service_type(fta_service_type_id: num, is_primary: true)
  end

  def primary_fta_mode_service
    "#{primary_fta_mode_type.code} #{primary_fta_service_type.code}"
  end

  # Render the asset as a JSON object -- overrides the default json encoding
  def as_json(options={})
    super.merge(
    {
      :fta_ownership_type_id => self.fta_ownership_type.present? ? self.fta_ownership_type.to_s : nil,
      :fta_bus_mode_type_id => self.fta_bus_mode_type.present? ? self.fta_bus_mode_type.to_s : nil,
      :ada_accessible_lift => self.ada_accessible_lift,
      :ada_accessible_ramp => self.ada_accessible_ramp,
      :fta_mode_types => self.fta_mode_types,
      :fta_service_types => self.fta_service_types,
      :pcnt_capital_responsibility => self.pcnt_capital_responsibility
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

  def direct_capital_responsibility
    new_record? || pcnt_capital_responsibility.present?
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

  # Set resonable defaults for a new fta vehicle
  def set_defaults
    super
    self.ada_accessible_lift ||= false
    self.fta_emergency_contingency_fleet ||= false
  end

end
