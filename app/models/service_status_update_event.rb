#
# Service Status Update Event. This is event type is required for
# all implementations and represents envets that change the service
# status of an asset: START SERVICE, SUSPEND SERVICE etc.
#
#
class ServiceStatusUpdateEvent < AssetEvent

  # Callbacks
  after_initialize :set_defaults
  after_save       :update_asset

  # Associations

  # Service Status of the asset
  belongs_to  :service_status_type


  validates :service_status_type_id, :presence => true

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_event_type_id => AssetEventType.find_by_class_name(self.name).id).order(:event_date, :created_at) }

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :service_status_type_id,
    :fta_emergency_contingency_fleet
  ]

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  #returns the asset event type for this type of event
  def self.asset_event_type
    AssetEventType.find_by_class_name(self.name)
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  def get_update
    "Service status changed to #{fta_emergency_contingency_fleet ? 'FTA Emergency Contingency Fleet' : ''} #{service_status_type}." unless service_status_type.nil?
  end

  # Set resonable defaults for a new condition update event
  def set_defaults
    super
    self.service_status_type ||= transam_asset.service_status_updates.last.try(:service_status_type) if transam_asset
    self.fta_emergency_contingency_fleet = self.fta_emergency_contingency_fleet.nil? ? false : self.fta_emergency_contingency_fleet
    self.asset_event_type ||= AssetEventType.find_by_class_name(self.name)
  end

  def update_asset
    transam_asset.very_specific.update(fta_emergency_contingency_fleet: self.fta_emergency_contingency_fleet) if (transam_asset.very_specific.respond_to? :fta_emergency_contingency_fleet)
  end

end
