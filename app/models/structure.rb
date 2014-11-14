#------------------------------------------------------------------------------
#
# Structure 
#
# Abstract class that adds physical structure attributes to the base TransitAsset class. All 
# structure assets should be drived from this base class
#
#------------------------------------------------------------------------------
class Structure < TransitAsset

  # Callbacks
  after_initialize  :set_defaults
    
  # Clean up any HABTM associations before the asset is destroyed
  before_destroy { fta_service_types.clear }
    
  #------------------------------------------------------------------------------
  # Associations common to all structures
  #------------------------------------------------------------------------------
            
  # The land for each structure is owned
  belongs_to                :land_ownership_type,         :class_name => "FtaOwnershipType",  :foreign_key => :land_ownership_type_id
  belongs_to                :land_owner_organization,     :class_name => "Organization",      :foreign_key => :land_owner_organization_id 

  # The building for each structure is owned
  belongs_to                :building_ownership_type,     :class_name => "FtaOwnershipType",  :foreign_key => :building_ownership_type_id
  belongs_to                :building_owner_organization, :class_name => "Organization",      :foreign_key => :building_owner_organization_id 
    
  # Each structure has a set (0 or more) of fta service type 
  has_and_belongs_to_many   :fta_service_types,           :foreign_key => 'asset_id'
    
  validates                 :description,                         :presence => :true  
  validates                 :address1,                            :presence => :true  
  validates                 :city,                                :presence => :true  
  validates                 :state,                               :presence => :true  
  validates                 :zip,                                 :presence => :true  
  validates                 :land_ownership_type_id,              :presence => :true
  validates                 :building_ownership_type_id,          :presence => :true
  validates                 :num_floors,                          :presence => :true, :numericality => {:only_integer => :true, :greater_than_or_equal_to => 1}  
  validates                 :num_structures,                      :presence => :true, :numericality => {:only_integer => :true, :greater_than_or_equal_to => 1}   
  validates                 :lot_size,                            :presence => :true, :numericality => {:greater_than_or_equal_to => 0}   
  validates                 :facility_size,                       :presence => :true, :numericality => {:greater_than_or_equal_to => 0}    
  validates                 :pcnt_operational,                    :presence => :true, :numericality => {:only_integer => :true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100}
      
  #------------------------------------------------------------------------------
  # Lists. These lists are used by derived classes to make up lists of attributes
  # that can be used for operations like full text search etc. Each derived class
  # can add their own fields to the list
  #------------------------------------------------------------------------------
    
  SEARCHABLE_FIELDS = [
    'description',
    'address1',
    'address2',
    'city',
    'state',
    'zip'
  ] 
  
  CLEANSABLE_FIELDS = [
    'description',
    'address1',
    'address2',
    'pcnt_operational'
  ] 
    
  # List of hash parameters specific to this class that are allowed by the controller
  FORM_PARAMS = [
    :description,
    :address1,
    :address2,
    :city,
    :state,
    :zip,
    :land_ownership_type_id,
    :building_ownership_type_id,
    :land_ownership_organization_id,
    :building_ownership_organization_id,
    :num_floors,
    :num_structures,
    :lot_size,
    :facility_size,
    :pcnt_operational,
    :ada_accessible_ramp
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
  
  # Override setters to remove any extraneous formats from the number strings eg $, etc.      
  def num_floors=(num)
    self[:num_floors] = sanitize_to_int(num)
  end      
  def num_structures=(num)
    self[:num_structures] = sanitize_to_int(num)
  end      
  def lot_size=(num)
    self[:lot_size] = sanitize_to_float(num)
  end      
  def facility_size=(num)
    self[:facility_size] = sanitize_to_float(num)
  end      
  def pcnt_operational=(num)
    self[:pcnt_operational] = sanitize_to_int(num)
  end      
  
  # Creates a duplicate that has all asset-specific attributes nilled
  def copy(cleanse = true)
    a = dup
    a.cleanse if cleanse
    a
  end
    
  # Override the name property
  def name
    description
  end

  # Get the full address of the structure  
  def full_address
    elems = []
    elems << address1 unless address1.blank?
    elems << address2 unless address2.blank?
    elems << city unless city.blank?
    elems << state unless state.blank?
    elems << zip unless zip.blank?
    elems.compact.join(', ')    
  end
  
  # override the cost property
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
    
  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Populates the location reference with the address of the structure
  def set_location_reference
    self.location_reference_type = LocationReferencType.find_by_format('ADDRESS')
    self.location_reference = full_address
  end
  
  # Set resonable defaults for a new generic structure
  def set_defaults
    super
    self.state ||= 'PA'
    self.location_reference_type ||= LocationReferenceType.find_by_format("NULL")
  end    

end
