class PerformanceRestrictionUpdateEvent < AssetEvent

  include TransamWorkflow
  include TransamSegmentable

  # Callbacks
  after_initialize :set_defaults
  before_save     :set_num_infrastructure

  belongs_to :infrastructure_chain_type

  belongs_to :performance_restriction_type

  scope :running,    -> {
    where(state: 'active')
        .or(PerformanceRestrictionUpdateEvent.where('asset_events.state = "started" AND asset_events.event_datetime <= ? AND asset_events.period_length IS NULL', DateTime.now))
        .or(PerformanceRestrictionUpdateEvent.where('asset_events.state = "started" AND asset_events.event_datetime <= ? AND ? <= (case when asset_events.period_length_unit="hour"
            then DATE_ADD(asset_events.event_datetime, INTERVAL asset_events.period_length HOUR)
               when asset_events.period_length_unit="day"
               then DATE_ADD(asset_events.event_datetime, INTERVAL asset_events.period_length DAY)
               when asset_events.period_length_unit="week"
               then DATE_ADD(asset_events.event_datetime, INTERVAL asset_events.period_length WEEK)
             end)', DateTime.now, DateTime.now)
        )
  }
  scope :expired,   -> { where(state: 'expired') }

  scope :active_in_range, -> (start_datetime, end_datetime) {
    where('asset_events.event_datetime <= ? AND asset_events.period_length IS NULL', start_datetime)
    .or(PerformanceRestrictionUpdateEvent.where('asset_events.event_datetime <= ? AND ? <= (case when asset_events.period_length_unit="hour"
            then DATE_ADD(asset_events.event_datetime, INTERVAL asset_events.period_length HOUR)
               when asset_events.period_length_unit="day"
               then DATE_ADD(asset_events.event_datetime, INTERVAL asset_events.period_length DAY)
               when asset_events.period_length_unit="week"
               then DATE_ADD(asset_events.event_datetime, INTERVAL asset_events.period_length WEEK)
             end)', start_datetime, end_datetime)
    )
  }

  #------------------------------------------------------------------------------
  #
  # State Machine
  #
  # Used to track the workflow
  #
  #------------------------------------------------------------------------------
  state_machine :state, initial: ->(s) { (s.period_length.nil? || DateTime.now <= s.start_datetime + s.period_length.send(s.period_length_unit.pluralize)) ? :started : :expired } do

    #-------------------------------
    # List of allowable states
    #-------------------------------

    state :started        # automated
    state :active         # user triggered
    state :expired        # automated or user triggered

    #---------------------------------------------------------------------------
    # List of allowable events.
    #---------------------------------------------------------------------------

    event :activate do
      transition [:expired] => :active
    end

    event :closeout do
      transition [:started, :active] => :expired
    end

    # Callbacks
    after_transition do |event, transition|
      Rails.logger.debug "Transitioned #{event} from #{transition.from_name} to #{transition.to_name} using #{transition.event}"


    end
  end


  # Validations
  validates :speed_restriction,                     presence: true, numericality: {less_than_or_equal_to: :max_permissible_speed }
  validates :speed_restriction_unit,                presence: true
  validates :from_line,                             presence: true, if: Proc.new{|a| a.transam_asset.infrastructure_segment_unit_type.name != 'Lat / Long'}
  validates :from_segment,                          presence: true, if: Proc.new{|a| a.transam_asset.infrastructure_segment_unit_type.name != 'Lat / Long'}
  validates :to_segment,                            presence: true, if: Proc.new{|a| a.to_line.present? }
  validates :to_segment,                            numericality: {greater_than_or_equal_to: :from_segment}, if: Proc.new{|a| a.transam_asset.infrastructure_segment_unit_type.name != 'Lat / Long' && a.from_line == a.to_line}
  validates :segment_unit,                          presence: true, if: Proc.new{|a| a.transam_asset.infrastructure_segment_unit_type.name == 'Marker Posts'}
  validates :infrastructure_chain_type_id,          presence: true, if: Proc.new{|a| a.transam_asset.infrastructure_segment_unit_type.name == 'Chaining'}
  validates :performance_restriction_type_id,       presence: true

  validates :event_date,                            presence: false
  validates :event_datetime,                        presence: true

  validate :segment_exists


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

  def max_permissible_speed
    transam_asset.max_permissible_speed
  end

  def tracks
    if transam_asset
      # searching all tracks of the transam asset's org should also include the transam asset of the event
      typed_asset = TransamAsset.get_typed_asset(transam_asset)
      typed_asset.get_segmentable_with_like_line_attributes(include_self: true).select { |track|
        track.overlaps(self)
      }
    end
  end

  def running?
    [:started, :active].include? state.to_sym
  end

  def start_datetime
    event_datetime
  end

  def end_datetime
    if state == 'expired'
      if workflow_events.empty? || workflow_events.last.creator == User.find_by(first_name: 'system') # automated. expired when entered or use period length
        event_datetime + period_length.to_i.send(period_length_unit.pluralize)
      else
        workflow_events.last.created_at
      end
    elsif state == 'started'
      if period_length.present? # if user set an end datetime otherwise until removed
        event_datetime + period_length.to_i.send(period_length_unit.pluralize)
      end
    else
      nil # if reactivated no end date time ie. until removed
    end
  end


  # This must be overriden otherwise a stack error will occur
  def get_update
    str = "Performance Restriction of #{speed_restriction} #{speed_restriction_unit}"

    segment_type = transam_asset.try(:infrastructure_segment_unit_type)

    if segment_type.present? && segment_type != InfrastructureSegmentUnitType.find_by(name: 'Lat / Long')
      str << " From: #{from_line} #{from_segment}"
      str << " - To: #{to_line} #{to_segment}" if to_line.present? || to_segment.present?
    end
    str << " for #{performance_restriction_type}"

    str
  end

  protected

  # Set resonable defaults for a new condition update event
  def set_defaults
    super
    self.asset_event_type ||= AssetEventType.find_by_class_name(self.name)

    self.from_line ||= transam_asset.try(:from_line)
    self.from_segment ||= transam_asset.try(:from_segment)
    self.to_line ||= transam_asset.try(:to_line)
    self.to_segment ||= transam_asset.try(:to_segment)
    self.segment_unit ||= transam_asset.try(:segment_unit)
    self.from_location_name ||= transam_asset.try(:from_location_name)
    self.to_location_name ||= transam_asset.try(:to_location_name)
    self.event_datetime ||= DateTime.now

    if self.start_datetime && self.state == 'started' && !self.new_record?
      unless self.start_datetime <= DateTime.now && (self.end_datetime.nil? || DateTime.now <= self.end_datetime)
        fire_state_event(:closeout)

        event = WorkflowEvent.new
        event.creator = User.find_by(first_name: 'system')
        event.accountable = self
        event.event_type = 'closeout'
        event.save
      end
    end
  end

  def set_num_infrastructure
    self.num_infrastructure = self.tracks.count
  end

  def segment_exists
    valid = false

    track = TransamAsset.get_typed_asset(transam_asset)
    like_segments = track.get_segmentable_with_like_line_attributes(include_self: true)


    valid =
        if like_segments.empty?
          track.overlaps(self)
        else
          track.overlaps(self) && (self.to_segment.nil? || (like_segments.minimum(:from_segment) <= self.from_segment && self.to_segment <= (like_segments.maximum(:to_segment) || self.to_segment)))
        end

    errors.add(:base, "The value entered falls outside the min (xxx.xx) - max (xxx.xx) range for Line: #{track.from_line}, Track: #{track.infrastructure_track}. Please enter a value that falls within the range.") unless valid

  end

end
