#------------------------------------------------------------------------------
#
# FtaFacility
#
# Abstract class that adds fta characteristics to a Structure asset
#
#------------------------------------------------------------------------------
class FtaFacility < Structure

  # Callbacks
  after_initialize :set_defaults
  after_save       :require_at_least_one_fta_mode_type     # validate model for HABTM relationships

  # Clean up any HABTM associations before the asset is destroyed
  before_destroy { fta_mode_types.clear }

  #------------------------------------------------------------------------------
  # Associations common to all fta facilites
  #------------------------------------------------------------------------------

  # Each facility has a set (0 or more) of fta mode type. This is the primary mode
  # serviced at the facility
  has_and_belongs_to_many   :fta_mode_types,              :foreign_key => :asset_id

  # Each facility must identify the FTA Facility type for NTD reporting
  belongs_to  :fta_facility_type

  #------------------------------------------------------------------------------
  # Validations common to all fta facilites
  #------------------------------------------------------------------------------
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
    :pcnt_capital_responsibility,
    :fta_facility_type_id,
    :primary_fta_mode_type_id,
    :fta_mode_type_ids => []
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

  def primary_fta_mode_type_id
    self.fta_mode_types.first.id unless self.fta_mode_types.first.nil?
  end

  # Override setters for primary_fta_mode_type for HABTM association
  def primary_fta_mode_type_id=(num)
    self.fta_mode_type_ids=([num])
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

  def require_at_least_one_fta_mode_type
    if fta_mode_types.count == 0
      errors.add(:fta_mode_types, "must be selected.")
      return false
    end
  end

  # Set resonable defaults for a new fta vehicle
  def set_defaults
    super
    self.pcnt_capital_responsibility ||= 100
  end

end
