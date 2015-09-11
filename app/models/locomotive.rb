#-------------------------------------------------------------------------------
#
# Locomotive
#
# Implementation class for a LOCOMOTIVE asset
#
#-------------------------------------------------------------------------------
class Locomotive < FtaVehicle

  # Enable auditing of this model type. Only monitor uodate and destroy events
  # has_paper_trail :on => [:update, :destroy]

  # Callbacks
  after_initialize :set_defaults

  # each vehicle has a type of fuel
  belongs_to                  :fuel_type

  #-----------------------------------------------------------------------------
  # Scopes
  #-----------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_type_id => AssetType.find_by_class_name(self.name).id) }

  #-----------------------------------------------------------------------------
  #
  # Class Methods
  #
  #-----------------------------------------------------------------------------

  def self.allowable_params
    [
      :fuel_type_id
    ]
  end

  #-----------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #-----------------------------------------------------------------------------

  # Render the asset as a JSON object -- overrides the default json encoding
  def as_json(options={})
    super.merge({})
  end

  # Creates a duplicate that has all asset-specific attributes nilled
  def copy(cleanse = true)
    a = dup
    a.cleanse if cleanse
    fta_service_types.each do |x|
      a.fta_service_types << x
    end
    fta_mode_types.each do |x|
      a.fta_mode_types << x
    end
    a
  end

  #-----------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #-----------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new locomotive
  def set_defaults
    super
    self.asset_type ||= AssetType.find_by_class_name(self.name)
  end

end
