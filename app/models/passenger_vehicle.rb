# --------------------------------
# # DEPRECATED see TTPLAT-1832 or https://wiki.camsys.com/pages/viewpage.action?pageId=51183790
# --------------------------------

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

  # Each vehicle has a single fta vehicle type
  belongs_to                :fta_vehicle_type

  # Each vehicle has a set (0 or more) of vehicle features
  has_and_belongs_to_many   :vehicle_features,    :foreign_key => 'asset_id'

  # These associations support the separation of service types into primary and secondary.
  has_one :secondary_assets_fta_service_type, -> { is_not_primary },
          class_name: 'AssetsFtaServiceType', :foreign_key => :asset_id
  has_one :secondary_fta_service_type, through: :secondary_assets_fta_service_type, source: :fta_service_type

  # These associations support the separation of mode types into primary and secondary.
  has_one :secondary_assets_fta_mode_type, -> { is_not_primary },
          class_name: 'AssetsFtaModeType', :foreign_key => :asset_id
  has_one :secondary_fta_mode_type, through: :secondary_assets_fta_mode_type, source: :fta_mode_type

  # ----------------------------------------------------
  # Vehicle Physical Characteristics
  # ----------------------------------------------------
  validates :seating_capacity,    :presence => true, :numericality => {:only_integer => true,   :greater_than_or_equal_to => 0}
  validates :standing_capacity,   :presence => true, :numericality => {:only_integer => true,   :greater_than_or_equal_to => 0}
  validates :wheelchair_capacity, :presence => true, :numericality => {:only_integer => true,   :greater_than_or_equal_to => 0}
  validates :vehicle_length,      :presence => true, :numericality => {:only_integer => true, :greater_than => 0}
  validates :fta_vehicle_type,    :presence => true

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    [
      :dedicated,
      :secondary_fta_mode_type_id,
      :secondary_fta_service_type_id,
      :fta_vehicle_type_id,
      :seating_capacity,
      :standing_capacity,
      :wheelchair_capacity,
      :vehicle_length,
      :vehicle_feature_ids => []
    ]
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  def secondary_fta_service_type_id
    secondary_fta_service_type.try(:id)
  end

  def secondary_fta_service_type_id=(value)
    if value.blank?
      self.secondary_assets_fta_service_type = nil
    else
      build_secondary_assets_fta_service_type(fta_service_type_id: value, is_primary: false)
    end
  end

  def secondary_fta_mode_type_id
    secondary_fta_mode_type.try(:id)
  end

  def secondary_fta_mode_type_id=(value)
    if value.blank?
      self.secondary_assets_fta_mode_type = nil
    else
      build_secondary_assets_fta_mode_type(fta_mode_type_id: value, is_primary: false)
    end
  end

  # Render the asset as a JSON object -- overrides the default json encoding
  def as_json(options={})
    super.merge(
    {
      :fta_vehicle_type_id => self.fta_vehicle_type.present? ? self.fta_vehicle_type.to_s : nil,
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
