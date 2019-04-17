#
# Usage codes update event. This event records the current use codes for a BPT asset
#
class UsageCodesUpdateEvent < AssetEvent
      
  # Callbacks
  after_initialize :set_defaults
  
  # Clean up any HABTM associations before the event is destroyed
  before_destroy { vehicle_usage_codes.clear }
      
  # Associations
  has_and_belongs_to_many   :vehicle_usage_codes,     :foreign_key => 'asset_event_id' 

  # Validations
  validates :vehicle_usage_codes, :presence => true
          
  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_event_type_id => AssetEventType.find_by_class_name(self.name).id).order(:event_date) }
    
  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :vehicle_usage_code_ids => []
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

  # This must be overriden otherwise a stack error will occur  
  def get_update
    "Codes: #{vehicle_usage_codes.join(', ')}"
  end

  protected

  # Set resonable defaults for a new condition update event
  def set_defaults
    super
    self.vehicle_usage_codes = (Rails.application.config.asset_base_class_name.constantize.get_typed_asset(self.send(Rails.application.config.asset_base_class_name.underscore)).usage_codes_updates.last.try(:vehicle_usage_codes) || []) if self.vehicle_usage_codes.blank?
    self.asset_event_type ||= AssetEventType.find_by_class_name(self.name)
  end    
  
end
