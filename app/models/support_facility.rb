# --------------------------------
# # DEPRECATED see TTPLAT-1832 or https://wiki.camsys.com/pages/viewpage.action?pageId=51183790
# --------------------------------
#
class SupportFacility < FtaBuilding

  # Callbacks
  after_initialize :set_defaults

  #------------------------------------------------------------------------------
  # Associations common to all service facilities
  #------------------------------------------------------------------------------

  # Each support facility has a capacity type
  belongs_to                :facility_capacity_type

  validates                 :facility_capacity_type,       :presence => true

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_type_id => AssetType.find_by_class_name(self.name).id) }

  #------------------------------------------------------------------------------
  # Lists. These lists are used by derived classes to make up lists of attributes
  # that can be used for operations like full text search etc. Each derived class
  # can add their own fields to the list
  #------------------------------------------------------------------------------

  SEARCHABLE_FIELDS = [
    :name
  ]
  CLEANSABLE_FIELDS = [
  ]
  # List of hash parameters specific to this class that are allowed by the controller
  FORM_PARAMS = [
    :facility_capacity_type_id
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

  # Render the asset as a JSON object -- overrides the default json encoding
  def as_json(options={})
    super.merge(
    {
      :facility_capacity => self.facility_capacity_type.present? ? self.facility_capacity_type.to_s : nil
    })
  end


  # Creates a duplicate that has all asset-specific attributes nilled
  def copy(cleanse = true)
    a = dup
    a.cleanse if cleanse
    a
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

  # Set resonable defaults for a suppoert facility
  def set_defaults
    super
    self.asset_type_id ||= AssetType.where(class_name: self.name).pluck(:id).first
  end

end
