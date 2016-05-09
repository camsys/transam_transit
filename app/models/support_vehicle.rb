#------------------------------------------------------------------------------
#
# SupportVehicle
#
# Implementation class for a Support Vehicle asset
#
#------------------------------------------------------------------------------
class SupportVehicle < FtaVehicle

  # Callbacks
  after_initialize :set_defaults

  #-----------------------------------------------------------------------------
  # Behaviors
  #-----------------------------------------------------------------------------

  #------------------------------------------------------------------------------
  # Associations common to all SupportVehicles
  #------------------------------------------------------------------------------

  # each asset has zero or more mileage updates. Only for vehicle assets.
  has_many   :mileage_updates, -> {where :asset_event_type_id => MileageUpdateEvent.asset_event_type.id }, :foreign_key => :asset_id, :class_name => "MileageUpdateEvent"

  # ----------------------------------------------------
  # Vehicle Physical Characteristics
  # ----------------------------------------------------
  validates :seating_capacity,           :presence => :true, :numericality => {:only_integer => :true, :greater_than_or_equal_to => 0}
  validates :fuel_type,                  :presence => :true
  validates :expected_useful_miles,      :presence => :true, :numericality => {:only_integer => :true, :greater_than_or_equal_to => 0}
  #validates :vin,                        :presence => :true, :length => {:is => 17 }, :format => { :with => /\A(?=.*[a-z])[a-z\d]+\Z/i }
  validates :serial_number,              :presence => :true
  validates :pcnt_capital_responsibility, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100}

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
    'license_plate',
    'serial_number'
  ]
  CLEANSABLE_FIELDS = [
    'license_plate',
    'serial_number'
  ]
  UPDATE_METHODS = [
    :update_mileage
  ]

  # List of hash parameters specific to this class that are allowed by the controller
  FORM_PARAMS = [
    :seating_capacity,
    :license_plate,
    :expected_useful_miles,
    :serial_number,
    :gross_vehicle_weight,
    :pcnt_capital_responsibility
  ]

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  def transfer new_organization_id
    transferred_asset = self.copy false
    org = Organization.where(:id => new_organization_id).first

    transferred_asset.fta_funding_type = nil
    transferred_asset.fta_ownership_type = nil
    transferred_asset.in_service_date = nil
    transferred_asset.organization = org
    transferred_asset.pcnt_capital_responsibility = nil
    transferred_asset.purchase_cost = nil
    transferred_asset.purchase_date = nil
    transferred_asset.purchased_new = false
    transferred_asset.service_status_type = nil
    transferred_asset.title_owner_organization_id = nil

    transferred_asset.generate_object_key(:object_key)
    transferred_asset.asset_tag = transferred_asset.object_key

    transferred_asset.save(:validate => false)

    return transferred_asset
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------


  def update_methods
    a = []
    a << super
    a += UPDATE_METHODS
    a.flatten
  end

  # Render the asset as a JSON object -- overrides the default json encoding
  def as_json(options={})
    super.merge(
    {
      :reported_mileage => self.reported_mileage,
      :last_maintenance_date => self.last_maintenance_date,
      :seating_capacity => self.seating_capacity,
      :license_plate => self.license_plate,
      :expected_useful_miles => self.expected_useful_miles,
      :serial_number => self.serial_number,
      :gross_vehicle_weight => self.gross_vehicle_weight,
      :pcnt_capital_responsibility => self.pcnt_capital_responsibility
    })
  end


  # Override numeric setters to remove any extraneous formats from the number strings eg $, etc.
  def expected_useful_miles=(num)
    self[:expected_useful_miles] = sanitize_to_int(num)
  end
  def seating_capacity=(num)
    self[:seating_capacity] = sanitize_to_int(num)
  end

  # Creates a duplicate that has all asset-specific attributes nilled
  def copy(cleanse = true)
    a = dup
    a.cleanse if cleanse
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

  # Forces an update of an assets mileage. This performs an update on the record. If a policy is passed
  # that policy is used to update the asset otherwise the default policy is used
  def update_mileage(policy = nil)

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

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new bus
  def set_defaults
    super
    self.seating_capacity ||= 0
    self.expected_useful_miles ||= 0
    self.asset_type ||= AssetType.find_by_class_name(self.name)
    self.pcnt_capital_responsibility ||= 100
  end

end
