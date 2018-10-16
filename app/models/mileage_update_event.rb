#
# Mileage update event. 
#
class MileageUpdateEvent < AssetEvent
      
  # Callbacks
  after_initialize :set_defaults
      
  # Associations
  belongs_to :transam_asset, class_name: 'ServiceVehicle', foreign_key: :transam_asset_id


  validates :current_mileage, :presence => true, :numericality => {:greater_than_or_equal_to => 0, :only_integer => true}
  validate  :monotonically_increasing_mileage
  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_event_type_id => AssetEventType.find_by_class_name(self.name).id).order(:event_date, :created_at) }
    
  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :current_mileage
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

  def current_mileage=(num)
    unless num.blank?
      self[:current_mileage] = sanitize_to_int(num)
    end
  end      

  # This must be overriden otherwise a stack error will occur  
  def get_update
    "Mileage recorded as #{current_mileage} miles." unless current_mileage.nil?
  end
  
  protected

  # Set resonable defaults for a new mileage update event
  def set_defaults
    super
    self.asset_event_type ||= AssetEventType.find_by_class_name(self.name)
  end    

  # Ensure that the mileage is between the previous (if any) and the following (if any)
  # Mileage must increase OR STAY THE SAME over time
  def monotonically_increasing_mileage
    if transam_asset
      previous_mileage_update = transam_asset.asset_events
                                    .where.not(current_mileage: nil)
                                    .where("event_date < ? OR (event_date = ? AND created_at < ?)", self.event_date, self.event_date, (self.new_record? ? Time.current : self.created_at) ) # Define a window that runs up to this event
                                    .where('object_key != ?', self.object_key)
                                    .order(:event_date, :created_at => :asc).last
      next_mileage_update = transam_asset.asset_events
                                .where.not(current_mileage: nil)
                                .where('event_date > ? OR (event_date = ? AND created_at > ?)', self.event_date, self.event_date, (self.new_record? ? Time.current : self.created_at )) # Define a window that backs up to this event
                                .where('object_key != ?', self.object_key)
                                .order(:event_date, :created_at => :desc).first

      if previous_mileage_update
        errors.add(:current_mileage, "can't be less than last update (#{previous_mileage_update.current_mileage})") if current_mileage < previous_mileage_update.current_mileage
      end
      if next_mileage_update
        errors.add(:current_mileage, "can't be more than next update (#{next_mileage_update.current_mileage})") if current_mileage > next_mileage_update.current_mileage
      end
    end
  end
  
end
