#-------------------------------------------------------------------------------
#
# Locomotive
#
# Implementation class for a LOCOMOTIVE asset
#
#-------------------------------------------------------------------------------
class Locomotive < FtaVehicle

  # Callbacks
  after_initialize :set_defaults

  # each vehicle has a type of fuel
  belongs_to                  :fuel_type

  # Each vehicle has a single fta vehicle type
  belongs_to                :fta_vehicle_type

  validates                 :fta_vehicle_type,         :presence => true

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
      :secondary_fta_mode_type_id,
      :secondary_fta_service_type_id,
      :fta_vehicle_type_id,
      :fuel_type_id
    ]
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

  #-----------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #-----------------------------------------------------------------------------

  # Render the asset as a JSON object -- overrides the default json encoding
  def as_json(options={})
    super.merge({
      :fta_vehicle_type_id => self.fta_vehicle_type.present? ? self.fta_vehicle_type.to_s : nil
    })
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

  def secondary_fta_service_type
    self.assets_fta_service_types.is_not_primary.first.try(:fta_service_type)
  end

  def secondary_fta_service_type_id
    self.assets_fta_service_types.is_not_primary.first.try(:fta_service_type_id)
  end

  def secondary_fta_service_type_id=(value)
    self.assets_fta_service_types.is_not_primary.delete_all
    self.assets_fta_service_types.build(fta_service_type_id: value, is_primary: false)
  end

  def secondary_fta_mode_type
    FtaModeType.where(id: self.assets_fta_mode_types.is_not_primary.pluck(:fta_mode_type_id)).first
  end

  def secondary_fta_mode_type_id
    secondary_fta_mode_type.try(:id)
  end

  def secondary_fta_mode_type_id=(value)
    self.assets_fta_mode_types.is_not_primary.delete_all
    self.assets_fta_mode_types.build(fta_mode_type_id: value, is_primary: false) unless value.blank?
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
    self.asset_type_id ||= AssetType.where(class_name: self.name).pluck(:id).first
  end

end
