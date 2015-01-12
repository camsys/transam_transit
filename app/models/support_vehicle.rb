#------------------------------------------------------------------------------
#
# SupportVehicle
#
# Implementation class for a Support Vehicle asset
#
#------------------------------------------------------------------------------
class SupportVehicle < FtaVehicle

  # Enable auditing of this model type. Only monitor uodate and destroy events
  has_paper_trail :on => [:update, :destroy]

  # Callbacks
  after_initialize :set_defaults

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
  validates :expected_useful_miles,      :presence => :true, :numericality => {:only_integer => :true, :greater_than => 0}
  #validates :vin,                        :presence => :true, :length => {:is => 17 }, :format => { :with => /\A(?=.*[a-z])[a-z\d]+\Z/i }
  validates :serial_number,              :presence => :true

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
    :serial_number
  ]

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end
  def self.update_methods
    UPDATE_METHODS
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  # Override numeric setters to remove any extraneous formats from the number strings eg $, etc.
  def expected_useful_miles=(num)
    self[:expected_useful_miles] = sanitize_to_int(num)
  end
  def seating_capacity=(num)
    self[:seating_capacity] = sanitize_to_int(num)
  end

  # initialize any policy-related items.
  def initialize_policy_items(init_policy = nil)
    super(init_policy)
    # Set the expected_useful_miles
    if init_policy
      p = init_policy
    else
      p = policy
    end
    if p
      policy_item = p.get_rule(self)
      if policy_item
        self.expected_useful_miles = policy_item.max_service_life_miles
      end
    end
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
        else
          event = mileage_updates.last
          self.reported_mileage = event.current_mileage
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
  end

end
