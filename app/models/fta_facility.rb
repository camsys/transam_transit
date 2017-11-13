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

  # Clean up any HABTM associations before the asset is destroyed
  before_destroy { :clean_habtm_relationships }

  #------------------------------------------------------------------------------
  # Associations common to all fta facilites
  #------------------------------------------------------------------------------

  # Each facility has a set (0 or more) of fta mode type. This is the primary mode
  # serviced at the facility
  has_many                  :assets_fta_mode_types,       :foreign_key => :asset_id
  has_and_belongs_to_many   :fta_mode_types,              :foreign_key => :asset_id

  # Each structure has a set (0 or more) of fta service type
  has_many                  :assets_fta_service_types,       :foreign_key => :asset_id
  has_and_belongs_to_many   :fta_service_types,           :foreign_key => 'asset_id'

  belongs_to  :fta_private_mode_type

  # Each facility must identify the FTA Facility type for NTD reporting
  belongs_to  :fta_facility_type

  #------------------------------------------------------------------------------
  # Validations common to all fta facilites
  #------------------------------------------------------------------------------
  validates   :fta_facility_type,   :presence => true
  validates   :pcnt_capital_responsibility, :numericality => {:only_integer => true,   :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100}
  validates   :primary_fta_mode_type, :presence => true

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    [
      :pcnt_capital_responsibility,
      :fta_facility_type_id,
      :primary_fta_mode_type_id,
      :primary_fta_service_type_id,
      :fta_private_mode_type_id,
      :fta_mode_type_ids => []
    ]
  end


  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  # Render the asset as a JSON object -- overrides the default json encoding
  def as_json(options={})
    super.merge(
    {
      :fta_mode_types => self.fta_mode_types,
      :fta_facility_type_id => self.fta_facility_type.present? ? self.fta_facility_type.to_s : nil,
      :pcnt_capital_responsibility => self.pcnt_capital_responsibility
    })
  end

  def primary_fta_mode_type_id
    self.assets_fta_mode_types.is_primary.first
  end

  # Override setters for primary_fta_mode_type for HABTM association
  def primary_fta_mode_type_id=(num)
    primary_mode = self.assets_fta_mode_types.find_or_initialize_by(is_primary: true)
    primary_mode.fta_mode_type_id = num
    primary_mode.save!
  end

  def primary_fta_service_type_id
    self.assets_fta_service_types.is_primary.first
  end

  # Override setters for primary_fta_mode_type for HABTM association
  def primary_fta_service_type_id=(num)
    primary_mode = self.assets_fta_service_types.find_or_initialize_by(is_primary: true)
    primary_mode.fta_service_type_id = num
    primary_mode.save!
  end

  def searchable_fields
    a = []
    a << super
    a += [:fta_facility_type]
    a.flatten
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  def clean_habtm_relationships
    fta_mode_types.clear
  end

  # Set resonable defaults for a new fta vehicle
  def set_defaults
    super
    self.pcnt_capital_responsibility ||= 100
  end

end
