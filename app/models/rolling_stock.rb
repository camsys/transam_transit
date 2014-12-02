#------------------------------------------------------------------------------
#
# RollingStock 
#
# Abstract class that adds vehicle/rolling stock attributes to the base TransitAsset class. 
# All concrete rolling stock assets should be drived from this base class
#
#------------------------------------------------------------------------------
class RollingStock < TransitAsset

  # Callbacks
  after_initialize    :set_defaults
  before_validation   :set_description
 
  #------------------------------------------------------------------------------
  # Associations common to all rolling stock
  #------------------------------------------------------------------------------

  # each vehicle has a type of fuel
  belongs_to                  :fuel_type
                
  # each vehicle's title is owned by an organization
  belongs_to                  :title_owner,         :class_name => "Organization", :foreign_key => 'title_owner_organization_id'

  # each has a storage method
  belongs_to                  :vehicle_storage_method_type
  
  # each vehicle has zero or more operations update events
  has_many   :operations_updates, -> {where :asset_event_type_id => OperationsUpdateEvent.asset_event_type.id }, :class_name => "OperationsUpdateEvent", :foreign_key => "asset_id"

  # each vehicle has zero or more operations update events
  has_many   :usage_updates,      -> {where :asset_event_type_id => UsageUpdateEvent.asset_event_type.id }, :class_name => "UsageUpdateEvent",  :foreign_key => "asset_id"

  # each asset has zero or more storage method updates. Only for rolling stock assets.
  has_many   :storage_method_updates, -> {where :asset_event_type_id => StorageMethodUpdateEvent.asset_event_type.id }, :class_name => "StorageMethodUpdateEvent", :foreign_key => "asset_id"

  # each asset has zero or more location updates.
  has_many   :location_updates, -> {where :asset_event_type_id => LocationUpdateEvent.asset_event_type.id }, :class_name => "LocationUpdateEvent",  :foreign_key => "asset_id"

  # ----------------------------------------------------  
  # Vehicle Physical Characteristics
  # ----------------------------------------------------  
  validates :manufacturer_id,     :presence => :true
  validates :manufacturer_model,  :presence => :true
  validates :title_owner_organization_id,        :presence => :true
  validates :rebuild_year,        :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 2000},  :allow_nil => true
  
  #------------------------------------------------------------------------------
  # Lists. These lists are used by derived classes to make up lists of attributes
  # that can be used for operations like full text search etc. Each derived class
  # can add their own fields to the list
  #------------------------------------------------------------------------------
    
  SEARCHABLE_FIELDS = [
    'purchase_date',
    'title_number',
    'description',
  ] 
  CLEANSABLE_FIELDS = [
    'title_number',
    'description'
  ] 
  UPDATE_METHODS = [
    :update_usage_metrics,
    :update_operations_metrics,
    :update_storage_method,
    :update_location
  ]

  # List of hash parameters specific to this class that are allowed by the controller
  FORM_PARAMS = [
    :title_number,
    :title_owner_organization_id,
    :expected_useful_miles,
    :reported_milage,
    :rebuild_year,
    :purchase_method_type_id,
    :description,
    :vehicle_storage_method_type_id,
    :fuel_type_id
  ]
  
  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------
    
  def self.allowable_params
    FORM_PARAMS
  end
    

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------
      
  # Rebuild year is optional so blanks are allowed
  def rebuild_year=(num)
    unless num.blank?
      self[:rebuild_year] = sanitize_to_int(num)
    end
  end   
       
  # Creates a duplicate that has all asset-specific attributes nilled
  def copy(cleanse = true)
    a = dup
    a.cleanse if cleanse
    a
  end
    
  # Override the name property
  def name
    super
  end
  
  # The cost of a vehicle is the purchase cost
  def cost
    purchase_cost
  end

  def searchable_fields
    a = []
    a << super
    SEARCHABLE_FIELDS.each do |field|
      a << field
    end
    a.flatten
  end
  
  def cleansable_fields
    a = []
    a << super
    CLEANSABLE_FIELDS.each do |field|
      a << field
    end
    a.flatten
  end

  def update_methods
    a = []
    a.append super
    UPDATE_METHODS.each do |method|
      a.append(method)
    end
    a
  end

  # Forces an update of an assets usage metrics. This performs an update on the record.
  def update_usage_metrics

    Rails.logger.info "Updating the recorded usage metrics for asset = #{object_key}"
    # nothing to do for now
    
  end
  
  # Forces an update of an assets operations metrics. This performs an update on the record.
  def update_operations_metrics

    Rails.logger.info "Updating the recorded operations metrics for asset = #{object_key}"
    # nothing to do for now
    
  end
    
    
  # Forces an update of an assets storage method. This performs an update on the record.
  def update_storage_method

    Rails.logger.info "Updating the recorded storage method for asset = #{object_key}"

    unless new_record?
      unless storage_method_updates.empty?
        event = storage_method_updates.last
        self.vehicle_storage_method_type = event.vehicle_storage_method_type
        save
      end
    end
  end

  # Forces an update of an assets location. This performs an update on the record.
  def update_location

    Rails.logger.info "Updating the recorded location for asset = #{object_key}"

    unless new_record?
      unless location_updates.empty?
        event = location_updates.last
        self.location_id = event.location_id
        self.location_comments = event.comments
        save
      end
    end
  end
    
  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set the description field
  def set_description
    self.description = "#{self.manufacturer.code} #{self.manufacturer_model}" unless self.manufacturer.nil?
  end
  
  # Set resonable defaults for a new rolling stock asset
  def set_defaults
    super
    self.vehicle_length ||= 0
  end    

end
