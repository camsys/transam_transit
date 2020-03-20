#
# Operations update event. This event records the current operations for a BPT asset
#
class OperationsUpdateEvent < AssetEvent
      
  # Callbacks
  after_initialize :set_defaults
            
  # Validations
  validates_numericality_of :avg_cost_per_mile,       :greater_than_or_equal_to => 0, :less_than => 100,   :allow_nil => true
  validates_numericality_of :avg_miles_per_gallon,    :greater_than_or_equal_to => 0, :less_than => 100,   :allow_nil => true
  validates_numericality_of :annual_maintenance_cost, :greater_than_or_equal_to => 0, :less_than => 100000,   :only_integer => true, :allow_nil => true
  validates_numericality_of :annual_insurance_cost,   :greater_than_or_equal_to => 0, :less_than => 100000,   :only_integer => true, :allow_nil => true
  validate :any_present? # validate that at least one of the fields is filled

      
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
    self[:avg_cost_per_mile] = sanitize_to_float(num) unless num.blank?
  end      
  def avg_miles_per_gallon=(num)
    self[:avg_miles_per_gallon] = sanitize_to_float(num) unless num.blank?
  end      
  def annual_maintenance_cost=(num)
    self[:annual_maintenance_cost] = sanitize_to_int(num) unless num.blank?
  end      
  def annual_insurance_cost=(num)
    self[:annual_insurance_cost] = sanitize_to_int(num) unless num.blank?
  end      
    

  # This must be overriden otherwise a stack error will occur  
  def get_update
    str = ""
    str += "Avg. Cost per Mile: #{avg_cost_per_mile} " unless avg_cost_per_mile.nil?
    str += "Avg. Miles per Gal: #{avg_miles_per_gallon} " unless avg_miles_per_gallon.nil?
    str += "Annual Maintenance Cost: #{annual_maintenance_cost} " unless annual_maintenance_cost.nil?
    str += "Annual Insurance Cost: #{annual_insurance_cost}" unless annual_insurance_cost.nil?
    str
  end

  ######## API Serializer ##############
  def api_json(options={})
    super.merge({
      avg_cost_per_mile: avg_cost_per_mile,
      avg_miles_per_gallon: avg_miles_per_gallon,
      annual_maintenance_cost: annual_maintenance_cost,
      annual_insurance_cost: annual_insurance_cost,
      actual_costs: actual_costs
    })
  end
  
  protected

  # Set resonable defaults for a new condition update event
  def set_defaults
    super
    self.asset_event_type ||= AssetEventType.find_by_class_name(self.name)
    prev_ops_update = self.previous_event_of_type
    if prev_ops_update
      self.avg_cost_per_mile       ||= prev_ops_update.avg_cost_per_mile
      self.avg_miles_per_gallon    ||= prev_ops_update.avg_miles_per_gallon
      self.annual_maintenance_cost ||= prev_ops_update.annual_maintenance_cost
      self.annual_insurance_cost   ||= prev_ops_update.annual_insurance_cost
    end
  end

  def any_present?
    if %w(annual_insurance_cost annual_maintenance_cost avg_miles_per_gallon avg_cost_per_mile).all?{|attr| self[attr].blank?}
      errors.add :base, "At least one metric must be entered"
    end
  end
  
end
