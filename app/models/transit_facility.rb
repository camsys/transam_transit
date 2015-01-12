class TransitFacility < FtaFacility

  # Enable auditing of this model type. Only monitor uodate and destroy events
  has_paper_trail :on => [:update, :destroy]

  # Callbacks
  after_initialize :set_defaults

  # Clean up any HABTM associations before the asset is destroyed
  before_destroy { :clean_habtm_relationships }

  #------------------------------------------------------------------------------
  # Associations common to all fta vehicles
  #------------------------------------------------------------------------------

  # Each transit facility has a set (0 or more) of fta mode type
  has_and_belongs_to_many   :fta_mode_types,              :foreign_key => 'asset_id'

  # Each transit facility has a set (0 or more) of facility features
  has_and_belongs_to_many   :facility_features,           :foreign_key => 'asset_id'

  validates :num_elevators,   :presence => true, :numericality => {:only_integer => :true, :greater_than_or_equal_to => 0}
  validates :num_escalators,  :presence => true, :numericality => {:only_integer => :true, :greater_than_or_equal_to => 0}

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
  ]
  CLEANSABLE_FIELDS = [
  ]
  # List of hash parameters specific to this class that are allowed by the controller
  FORM_PARAMS = [
    :num_elevators,
    :num_escalators,
    :facility_feature_ids => [],
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

  def clean_habtm_relationships
    fta_mode_types.clear
    facility_features.clear
  end

  # Set resonable defaults for a new bus
  def set_defaults
    super
    self.asset_type ||= AssetType.find_by_class_name(self.name)
    self.num_elevators ||= 0
    self.num_escalators ||= 0
  end

end
