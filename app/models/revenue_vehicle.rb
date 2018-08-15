class RevenueVehicle < TransamAssetRecord
  acts_as :service_vehicle, as: :service_vehiclible

  after_initialize :set_defaults

  before_destroy do
    fta_service_types.clear
    vehicle_features.clear
  end

  belongs_to :esl_category
  belongs_to :fta_funding_type
  belongs_to :fta_ownership_type

  # Each vehicle has a set (0 or more) of vehicle features
  has_and_belongs_to_many   :vehicle_features,    :foreign_key => :transam_asset_id,    :join_table => :assets_vehicle_features

  # Each vehicle has a set (0 or more) of fta service type
  has_many                  :assets_fta_service_types,       :foreign_key => :transam_asset_id,    :join_table => :assets_fta_service_types
  has_and_belongs_to_many   :fta_service_types,           :foreign_key => :transam_asset_id,    :join_table => :assets_fta_service_types

  # These associations support the separation of service types into primary and secondary.
  has_one :primary_assets_fta_service_type, -> { is_primary },
          class_name: 'AssetsFtaServiceType', :foreign_key => :transam_asset_id
  has_one :primary_fta_service_type, through: :primary_assets_fta_service_type, source: :fta_service_type

  # These associations support the separation of service types into primary and secondary.
  has_one :secondary_assets_fta_service_type, -> { is_not_primary },
          class_name: 'AssetsFtaServiceType', :foreign_key => :transam_asset_id
  has_one :secondary_fta_service_type, through: :secondary_assets_fta_service_type, source: :fta_service_type

  # These associations support the separation of mode types into primary and secondary.
  has_one :secondary_assets_fta_mode_type, -> { is_not_primary },
          class_name: 'AssetsFtaModeType', :foreign_key => :transam_asset_id
  has_one :secondary_fta_mode_type, through: :secondary_assets_fta_mode_type, source: :fta_mode_type

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------

  validates :esl_category_id, presence: true
  validates :standing_capacity, presence: true
  validates :fta_funding_type_id, presence: true
  validates :fta_ownership_type_id, presence: true
  validates :dedicated, inclusion: { in: [ true, false ] }
  validates :fta_ownership_type_id, inclusion: {in: FtaOwnershipType.where(name: 'Other').pluck(:id)}, if: Proc.new{|a| a.other_fta_ownership_type.present?}
  validate :primary_and_secondary_cannot_match
  validates :primary_fta_service_type, presence: true
  validates :primary_fta_mode_type, presence: true

  def primary_and_secondary_cannot_match
    if primary_fta_mode_type != nil 
      if (primary_fta_mode_type == secondary_fta_mode_type) and (primary_fta_service_type == secondary_fta_service_type)
        errors.add(:primary_fta_mode_type, "cannot match secondary mode")
      end
    end
  end

  FORM_PARAMS = [
      :esl_category_id,
      :standing_capacity,
      :fta_funding_type_id,
      :fta_ownership_type_id,
      :other_fta_ownership_type,
      :dedicated
  ]

  CLEANSABLE_FIELDS = [

  ]

  def dup
    super.tap do |new_asset|
      new_asset.fta_service_types = self.fta_service_types
      new_asset.vehicle_features = self.vehicle_features
      new_asset.service_vehicle = self.service_vehicle.dup
    end
  end

  def transfer new_organization_id
    transferred_asset = super(new_organization_id)
    transferred_asset.fta_ownership_type = nil
    transferred_asset.license_plate = nil
    transferred_asset.save(validate: false)

    transferred_asset.mileage_updates << self.mileage_updates.last.dup if self.mileage_updates.count > 0

    return transferred_asset
  end

  def primary_fta_service_type_id
    primary_fta_service_type.try(:id)
  end

  # Override setters for primary_fta_mode_type for HABTM association
  def primary_fta_service_type_id=(num)
    build_primary_assets_fta_service_type(fta_service_type_id: num, is_primary: true)
  end

  def primary_fta_mode_service
    "#{primary_fta_mode_type.try(:code)} #{primary_fta_service_type.try(:code)}"
  end

  def secondary_fta_service_type_id
    secondary_fta_service_type.try(:id)
  end

  def secondary_fta_service_type_id=(value)
    if value.blank?
      self.secondary_assets_fta_service_type = nil
    else
      build_secondary_assets_fta_service_type(fta_service_type_id: value, is_primary: false)
    end
  end

  def secondary_fta_mode_type_id
    secondary_fta_mode_type.try(:id)
  end

  def secondary_fta_mode_type_id=(value)
    if value.blank?
      self.secondary_assets_fta_mode_type = nil
    else
      build_secondary_assets_fta_mode_type(fta_mode_type_id: value, is_primary: false)
    end
  end

  protected

  def set_defaults
    self.dedicated = self.dedicated.nil? ? true: self.dedicated
  end

  # link to old asset if no instance method in chain
  def method_missing(method, *args, &block)
    if !self_respond_to?(method) && acting_as.respond_to?(method)
      acting_as.send(method, *args, &block)
    elsif !self_respond_to?(method) && typed_asset.respond_to?(method)
      puts "You are calling the old asset for this method #{method}"
      Rails.logger.warn "You are calling the old asset for this method #{method}"
      typed_asset.send(method, *args, &block)
    else
      super
    end
  end

end
