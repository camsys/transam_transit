#------------------------------------------------------------------------------
#
# FtaFacility
#
# Abstract class that adds fta characteristics to a Structure asset
#
#------------------------------------------------------------------------------
class FtaVehicle < Structure

  # Callbacks
  after_initialize :set_defaults
  after_save       :require_at_least_one_fta_mode_type     # validate model for HABTM relationships

  # Clean up any HABTM associations before the asset is destroyed
  before_destroy { :clean_habtm_relationships }

  #------------------------------------------------------------------------------
  # Associations common to all fta facilites
  #------------------------------------------------------------------------------

  # Each facility has a set (0 or more) of fta mode type. This is the primary mode
  # serviced at the facility
  belongs_to  :fta_mode_type

  # Each facility must identify the FTA Facility type for NTD reporting
  belongs_to  :fta_facility_type

  #------------------------------------------------------------------------------
  # Validations common to all fta facilites
  #------------------------------------------------------------------------------
  validates   :fta_mode_type,       :presence => :true
  validates   :fta_facility_type,   :presence => :true
  validates   :pcnt_capital_responsibility, :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100}

  #------------------------------------------------------------------------------
  # Lists. These lists are used by derived classes to make up lists of attributes
  # that can be used for operations like full text search etc. Each derived class
  # can add their own fields to the list
  #------------------------------------------------------------------------------

  SEARCHABLE_FIELDS = [
  ]
  CLEANSABLE_FIELDS = [
  ]

  # List of hash parameters specific to this class that are allowed by the controller
  FORM_PARAMS = [
    :fta_mode_type_id,
    :fta_facility_type
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

  # Set resonable defaults for a new fta vehicle
  def set_defaults
    super
    self.pcnt_capital_responsibility ||= 100
  end

end
