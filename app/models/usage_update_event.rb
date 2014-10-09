#
# Usage update event. This event records the current use for a BPT asset
#
class UsageUpdateEvent < AssetEvent
      
  # Callbacks
  after_initialize :set_defaults
            
  validates :pcnt_5311_routes,          :numericality => {:greater_than_or_equal_to => 0, :less_than_or_equal_to => 100}, :allow_nil => true
  validates :avg_daily_use,             :numericality => {:greater_than_or_equal_to => 0, :less_than_or_equal_to => 24}, :allow_nil => true
  validates :avg_daily_passenger_trips, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}, :allow_nil => true
  validate  :any_present? # validate that at least one of the fields is filled
    
  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_event_type_id => AssetEventType.find_by_class_name(self.name).id).order(:event_date) }
    
  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :pcnt_5311_routes,
    :avg_daily_use,
    :avg_daily_passenger_trips
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
  def pcnt_5311_routes=(num)
    self[:pcnt_5311_routes] = sanitize_to_float(num) unless num.blank?
  end      
  def avg_daily_use=(num)
    self[:avg_daily_use] = sanitize_to_float(num) unless num.blank?
  end      
  def avg_daily_passenger_trips=(num)
    self[:avg_daily_passenger_trips] = sanitize_to_int(num) unless num.blank?
  end      

  # This must be overriden otherwise a stack error will occur  
  def get_update
    pcnt_5311_routes
  end

  protected

  # Set resonable defaults for a new condition update event
  def set_defaults
    super
    if new_record?
      prev_use_update = self.previous_event_of_type
      if prev_use_update
        self.pcnt_5311_routes          = prev_use_update.pcnt_5311_routes
        self.avg_daily_use             = prev_use_update.avg_daily_use
        self.avg_daily_passenger_trips = prev_use_update.avg_daily_passenger_trips
      end
    end
    self.asset_event_type ||= AssetEventType.find_by_class_name(self.name)
  end    

  def any_present?
    if %w(pcnt_5311_routes avg_daily_use avg_daily_passenger_trips).all?{|attr| self[attr].blank?}
      errors.add :base, "At least one metric must be entered"
    end
  end
  
end
