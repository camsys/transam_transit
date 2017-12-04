class TransitFacility < FtaFacility

  # Callbacks
  after_initialize :set_defaults

  # Clean up any HABTM associations before the asset is destroyed
  before_destroy { :clean_habtm_relationships }

  #------------------------------------------------------------------------------
  # Associations common to all fta vehicles
  #------------------------------------------------------------------------------

  # Each transit facility has a set (0 or more) of facility features
  has_and_belongs_to_many   :facility_features,           :foreign_key => 'asset_id'

  validates :num_elevators,   :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  validates :num_escalators,  :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  validates_inclusion_of :ada_accessible_ramp, :in => [true, false]

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

  SEARCHABLE_FIELDS =

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    [
      :num_elevators,
      :num_escalators,
      :facility_feature_ids => []
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
      :facility_features => self.facility_features,
      :num_elevators => self.num_elevators,
      :num_escalators => self.num_escalators
    })
  end

  # Override setters to remove any extraneous formats from the number strings eg $, etc.
  def num_elevators=(num)
    self[:num_elevators] = sanitize_to_int(num)
  end
  def num_escalators=(num)
    self[:num_escalators] = sanitize_to_int(num)
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
    a += [:name]
    a.flatten
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  def clean_habtm_relationships
    facility_features.clear
  end

  # Set resonable defaults for a new bus
  def set_defaults
    super
    self.asset_type_id ||= AssetType.where(class_name: self.name).pluck(:id).first
    self.num_elevators ||= 0
    self.num_escalators ||= 0
  end

end
