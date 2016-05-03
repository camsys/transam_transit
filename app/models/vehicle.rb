#------------------------------------------------------------------------------
#
# Vehicle
#
# Implementation class for a Vehicle asset
#
#------------------------------------------------------------------------------
class Vehicle < PassengerVehicle

  # Callbacks
  after_initialize :set_defaults

  # Clean up any HABTM associations before the asset is destroyed
  before_destroy { :clean_habtm_relationships }

  #-----------------------------------------------------------------------------
  # Behaviors
  #-----------------------------------------------------------------------------

  #------------------------------------------------------------------------------
  # Associations common to all Vehicles
  #------------------------------------------------------------------------------

  # each asset has a rebuild type
  belongs_to  :vehicle_rebuild_type

  # each asset has zero or more mileage updates. Only for vehicle assets.
  has_many   :mileage_updates, -> {where :asset_event_type_id => MileageUpdateEvent.asset_event_type.id }, :foreign_key => :asset_id, :class_name => "MileageUpdateEvent"

  # each asset has zero or more usage codes updates. Only for vehicle assets.
  has_many   :usage_codes_updates, -> {where :asset_event_type_id => UsageCodesUpdateEvent.asset_event_type.id }, :foreign_key => :asset_id, :class_name => "UsageCodesUpdateEvent"

  has_and_belongs_to_many   :vehicle_usage_codes, :foreign_key => :asset_id

  # ----------------------------------------------------
  # Vehicle Physical Characteristics
  # ----------------------------------------------------
  validates :fuel_type,                 :presence => :true
  validates :expected_useful_miles,      :presence => :true, :numericality => {:only_integer => :true, :greater_than_or_equal_to => 0}
  #validates :serial_number,               :presence => :true, :length => {:is => 17 }, :format => { :with => /\A(?=.*[a-z])[a-z\d]+\Z/i }
  validates :serial_number,              :presence => :true

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_type_id => AssetType.find_by_class_name(self.name).id) }

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    [
      :license_plate,
      :serial_number,
      :gross_vehicle_weight,
      :vehicle_rebuild_type_id,
      :vehicle_usage_code_ids => []
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
      :reported_mileage => self.reported_mileage,
      :last_maintenance_date => self.last_maintenance_date,
      :license_plate => self.license_plate,
      :serial_number => self.serial_number,
      :gross_vehicle_weight => self.gross_vehicle_weight,
      :vehicle_usage_codes => self.vehicle_usage_codes,
      :vehicle_rebuild_type_id => self.vehicle_rebuild_type.present? ? self.vehicle_rebuild_type.to_s : nil
    })
  end

  # Override numeric setters to remove any extraneous formats from the number strings eg $, etc.
  def expected_useful_miles=(num)
    self[:expected_useful_miles] = sanitize_to_int(num)
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
    a += ['license_plate', 'serial_number']
    a.flatten
  end

  def cleansable_fields
    a = []
    a << super
    a += ['license_plate','serial_number']
    a.flatten
  end

  def update_methods
    a = []
    a << super
    a += [:update_mileage, :update_usage_codes]
    a.flatten
  end

  # Forces an update of an assets mileage.
  def update_mileage

    Rails.logger.info "Updating the recorded mileage method for asset = #{object_key}"

    # can't do this if it is a new record as none of the IDs would be set
    unless new_record?
      # Update the reported mileage
      begin
        if mileage_updates.empty?
          self.reported_mileage = 0
          self.reported_mileage_date = nil
        else
          event = mileage_updates.last
          self.reported_mileage = event.current_mileage
          self.reported_mileage_date = event.event_date
        end
        save
      rescue Exception => e
        Rails.logger.warn e.message
      end
    end

  end

  def update_usage_codes

    Rails.logger.info "Updating the recorded vehicle usage codes for asset = #{object_key}"

    unless new_record?
      if usage_codes_updates.empty?
        vehicle_usage_codes.clear
      else
        event = usage_codes_updates.last
        # remove the existing vehicle usage codes. These are commited immediately so no need to save
        vehicle_usage_codes.clear
        event.vehicle_usage_codes.each do |code|
          vehicle_usage_codes << code
        end
      end
    end
  end

  def transfer new_organization_id
    transferred_asset = self.copy
    org = Organization.where(:id => new_organization_id).first

    transferred_asset.fta_funding_type = nil
    transferred_asset.fta_ownership_type = nil
    transferred_asset.in_service_date = nil
    transferred_asset.organization = org
    transferred_asset.purchase_cost = nil
    transferred_asset.purchase_date = nil
    transferred_asset.service_status_type = nil
    transferred_asset.title_owner_organization_id = nil

    transferred_asset.generate_object_key(:object_key)
    transferred_asset.asset_tag = transferred_asset.object_key

    transferred_asset.save(:validate => false)
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  def clean_habtm_relationships
    vehicle_usage_codes.clear
  end

  # Set resonable defaults for a new bus
  def set_defaults
    super
    self.expected_useful_miles ||= 0
    self.asset_type ||= AssetType.find_by_class_name(self.name)
  end

end
