# --------------------------------
# # DEPRECATED see TTPLAT-1832 or https://wiki.camsys.com/pages/viewpage.action?pageId=51183790
# --------------------------------

#------------------------------------------------------------------------------
#
# Rail Car
#
# Implementation class for a RAIL CAR asset
#
#------------------------------------------------------------------------------
class RailCar < PassengerVehicle

  # Callbacks
  after_initialize :set_defaults


  # each asset has zero or more mileage updates. Only for vehicle assets.
  has_many    :mileage_updates, -> {where :asset_event_type_id => MileageUpdateEvent.asset_event_type.id }, :foreign_key => :asset_id, :class_name => "MileageUpdateEvent"

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_type_id => AssetType.find_by_class_name(self.name).id) }

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------
  def self.allowable_params
    []
  end


  def transfer new_organization_id
    org = Organization.where(:id => new_organization_id).first

    transferred_asset = self.copy false
    transferred_asset.object_key = nil

    transferred_asset.disposition_date = nil
    transferred_asset.fta_funding_type = nil
    transferred_asset.fta_ownership_type = FtaOwnershipType.find_by(:name => 'Unknown')
    transferred_asset.in_service_date = nil
    transferred_asset.organization = org
    transferred_asset.purchase_cost = nil
    transferred_asset.purchase_date = nil
    transferred_asset.purchased_new = false
    transferred_asset.service_status_type = nil
    transferred_asset.title_owner_organization_id = nil

    transferred_asset.generate_object_key(:object_key)
    transferred_asset.asset_tag = transferred_asset.object_key

    transferred_asset.save(:validate => false)

    return transferred_asset
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  # Render the asset as a JSON object -- overrides the default json encoding
  def as_json(options={})
    super.merge({})
  end

  # Creates a duplicate that has all asset-specific attributes nilled
  def copy(cleanse = true)
    a = dup
    a.cleanse if cleanse
    vehicle_features.each do |x|
      a.vehicle_features << x
    end
    fta_service_types.each do |x|
      a.fta_service_types << x
    end
    fta_mode_types.each do |x|
      a.fta_mode_types << x
    end
    a
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new raAil car
  def set_defaults
    super
    self.asset_type_id ||= AssetType.where(class_name: self.name).pluck(:id).first
  end

end
