#
# Operations update event. This event records the current operations for a BPT asset
#
class OperationsUpdateEvent < AssetEvent
      
  # Callbacks
  after_initialize :set_defaults
            
  # Validations
  validates_numericality_of :avg_cost_per_mile,               :greater_than_or_equal_to => 0,   :allow_nil => :true
  validates_numericality_of :avg_miles_per_gallon,            :greater_than_or_equal_to => 0,   :allow_nil => :true
  validates_numericality_of :annual_maintenance_cost,         :greater_than_or_equal_to => 0,   :only_integer => true, :allow_nil => :true
  validates_numericality_of :annual_insurance_cost,           :greater_than_or_equal_to => 0,   :only_integer => true, :allow_nil => :true
      
  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_event_type_id => AssetEventType.find_by_class_name(self.name).id).order(:event_date) }
    
  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :avg_cost_per_mile,
    :avg_miles_per_gallon,
    :annual_maintenance_cost,
    :annual_insurance_cost,
    :actual_costs
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
  def avg_cost_per_mile=(num)
    self[:avg_cost_per_mile] = sanitize_to_float(num)
  end      
  def avg_miles_per_gallon=(num)
    self[:avg_miles_per_gallon] = sanitize_to_float(num)
  end      
  def annual_maintenance_cost=(num)
    self[:annual_maintenance_cost] = sanitize_to_int(num)
  end      
  def annual_insurance_cost=(num)
    self[:annual_insurance_cost] = sanitize_to_int(num)
  end      
    

  # This must be overriden otherwise a stack error will occur  
  def get_update
    avg_cost_per_mile unless avg_cost_per_mile.nil?
  end
  
  protected

  # Set resonable defaults for a new condition update event
  def set_defaults
    super
    self.asset_event_type ||= AssetEventType.find_by_class_name(self.name)
  end    
  
end
