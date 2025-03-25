#
# Appraisal update event.
#
class AppraisalUpdateEvent < AssetEvent

  # Callbacks
  after_initialize :set_defaults
  validates :assessed_value, presence: true

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_event_type_id => AssetEventType.find_by_class_name(self.name).id).order(:event_date, :created_at) }

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :assessed_value
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
    "Asset value appraised at $#{assessed_value}" unless assessed_value.nil?
  end

  # Set resonable defaults for a new appraisal update event
  def set_defaults
    super
    self.event_date ||= Date.today
    self.asset_event_type ||= AssetEventType.find_by_class_name(self.name)
  end

  ######## API Serializer ##############
  def api_json(options={})
    super.merge({
      assessed_valued: assessed_value
    })
  end
  
end
