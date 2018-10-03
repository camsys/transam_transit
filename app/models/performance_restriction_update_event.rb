class PerformanceRestrictionUpdateEvent < AssetEvent

  # Callbacks
  after_initialize :set_defaults

  belongs_to :transam_asset, class_name: 'Infrastructure', foreign_key: :transam_asset_id

  belongs_to :performance_restriction_type

  # Validations
  validates :speed_restriction,                     presence: true
  validates :speed_restriction_unit,                presence: true
  validates :infrastructure_segment_unit_type_id,   presence: true
  validates :from_line,                             presence: true, if: Proc.new{|a| a.infrastructure_segment_unit_type.name != 'Lat / Long'}
  validates :from_segment,                          presence: true, if: Proc.new{|a| a.infrastructure_segment_unit_type.name != 'Lat / Long'}
  validates :segment_unit,                          presence: true, if: Proc.new{|a| a.infrastructure_segment_unit_type.name == 'Marker Posts'}
  validates :infrastructure_chain_type_id,          presence: true, if: Proc.new{|a| a.infrastructure_segment_unit_type.name == 'Chaining'}
  validates :performance_restriction_type_id,       presence: true

  validates :event_date,                            presence: false
  validates :event_datetime,                        presence: true


  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_event_type_id => AssetEventType.find_by_class_name(self.name).id).order(:event_datetime, :created_at) }

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
      :speed_restriction,
      :speed_restriction_unit,
      :period_length,
      :period_length_unit,
      :from_line,
      :to_line,
      :infrastructure_segment_unit_type_id,
      :from_segment,
      :to_segment,
      :segment_unit,
      :from_location_name,
      :to_location_name,
      :infrastructure_chain_type_id,
      :relative_location,
      :relative_location_unit,
      :relative_location_direction,
      :performance_restriction_type_id,
      :event_datetime
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
    str = "Restricted to #{speed_restriction} #{speed_restriction_unit}"
    if period_length.present?
      str += " for #{period_length} #{period_length_unit.pluralize}"
    else
      str += " until removed"
    end

    str
  end

  protected

  # Set resonable defaults for a new condition update event
  def set_defaults
    super
    self.asset_event_type ||= AssetEventType.find_by_class_name(self.name)
  end

end
