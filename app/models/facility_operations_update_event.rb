#
# Facility operations update event. This event records the current operations for a facility
#
class FacilityOperationsUpdateEvent < AssetEvent

  # Callbacks
  after_initialize :set_defaults

  # Validations
  validates_numericality_of :annual_affected_ridership,       :greater_than_or_equal_to => 0, :only_integer => true, :allow_nil => true
  validates_numericality_of :annual_dollars_generated,    :greater_than_or_equal_to => 0, :only_integer => true, :allow_nil => true
  validate :any_present? # validate that at least one of the fields is filled


  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_event_type_id => AssetEventType.find_by_class_name(self.name).id).order(:event_date) }

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :annual_affected_ridership,
    :annual_dollars_generated
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

  # Override setters to remove any extraneous formats from the number strings eg $, etc.
  def annual_affected_ridership=(num)
    self[:annual_affected_ridership] = sanitize_to_int(num) unless num.blank?
  end
  def annual_dollars_generated=(num)
    self[:annual_dollars_generated] = sanitize_to_int(num) unless num.blank?
  end


  # This must be overriden otherwise a stack error will occur
  def get_update
    annual_affected_ridership unless annual_affected_ridership.nil?
  end

  ######## API Serializer ##############
  def api_json(options={})
    super.merge({
      annual_affected_ridership: annual_affected_ridership,
      annual_dollars_generated: annual_dollars_generated
    })
  end

  protected

  # Set resonable defaults for a new condition update event
  def set_defaults
    super
    self.asset_event_type ||= AssetEventType.find_by_class_name(self.name)
    prev_ops_update = self.previous_event_of_type
    if prev_ops_update
      self.annual_affected_ridership  ||= prev_ops_update.annual_affected_ridership
      self.annual_dollars_generated    ||= prev_ops_update.annual_dollars_generated
    end
  end

  def any_present?
    if %w(annual_affected_ridership annual_dollars_generated).all?{|attr| self[attr].blank?}
      errors.add :base, "At least one metric must be entered"
    end
  end

end
