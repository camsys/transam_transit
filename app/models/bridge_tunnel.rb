# --------------------------------
# # DEPRECATED see TTPLAT-1832 or https://wiki.camsys.com/pages/viewpage.action?pageId=51183790
# --------------------------------

class BridgeTunnel < Structure

  # Callbacks
  after_initialize :set_defaults

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
    a = super
    SEARCHABLE_FIELDS.each do |field|
      a << field
    end
    a
  end

  def cleansable_fields
    a = super
    CLEANSABLE_FIELDS.each do |field|
      a << field
    end
    a
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new bridge or tunnel
  def set_defaults
    super
    self.asset_type_id ||= AssetType.where(class_name: self.name).pluck(:id).first
  end

end
