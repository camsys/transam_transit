class ServiceVehicle < TransamAssetRecord
acts_as :transit_asset, as: :transit_assetible
  actable as: :service_vehiclible

  before_destroy { fta_mode_types.clear }

  belongs_to :chassis
  belongs_to :fuel_type
  belongs_to :dual_fuel_type
  belongs_to :ramp_manufacturer

  # Each vehicle has a set (0 or more) of fta mode type
  has_many                  :assets_fta_mode_types,       :foreign_key => :transit_asset_id,    :join_table => :assets_fta_mode_types
  has_and_belongs_to_many   :fta_mode_types,              :foreign_key => :transit_asset_id,    :join_table => :assets_fta_mode_types

  # These associations support the separation of mode types into primary and secondary.
  has_one :primary_assets_fta_mode_type, -> { is_primary },
          class_name: 'AssetsFtaModeType', :foreign_key => :transit_asset_id
  has_one :primary_fta_mode_type, through: :primary_assets_fta_mode_type, source: :fta_mode_type

  # These associations support the separation of mode types into primary and secondary.
  has_many :secondary_assets_fta_mode_types, -> { is_not_primary }, class_name: 'AssetsFtaModeType', :foreign_key => :transit_asset_id,    :join_table => :assets_fta_service_types
  has_many :secondary_fta_mode_types, through: :secondary_assets_fta_mode_types, source: :fta_mode_type,    :join_table => :assets_fta_mode_types


  # each vehicle has zero or more operations update events
  has_many   :operations_updates, -> {where :asset_event_type_id => OperationsUpdateEvent.asset_event_type.id }, :class_name => "OperationsUpdateEvent", :foreign_key => "transam_asset_id"

  # each vehicle has zero or more operations update events
  has_many   :vehicle_usage_updates,      -> {where :asset_event_type_id => VehicleUsageUpdateEvent.asset_event_type.id }, :class_name => "VehicleUsageUpdateEvent",  :foreign_key => "transam_asset_id"

  # each asset has zero or more storage method updates. Only for rolling stock assets.
  has_many   :storage_method_updates, -> {where :asset_event_type_id => StorageMethodUpdateEvent.asset_event_type.id }, :class_name => "StorageMethodUpdateEvent", :foreign_key => "transam_asset_id"

  # each asset has zero or more usage codes updates. Only for vehicle assets.
  has_many   :usage_codes_updates, -> {where :asset_event_type_id => UsageCodesUpdateEvent.asset_event_type.id }, :foreign_key => :transam_asset_id, :class_name => "UsageCodesUpdateEvent"

  # each asset has zero or more mileage updates. Only for vehicle assets.
  has_many    :mileage_updates, -> {where :asset_event_type_id => MileageUpdateEvent.asset_event_type.id }, :foreign_key => :transam_asset_id, :class_name => "MileageUpdateEvent"

  FORM_PARAMS = [
    :serial_number,
    :chassis_id,
    :other_chassis,
    :fuel_type_id,
    :dual_fuel_type_id,
    :other_fuel_type,
    :license_plate,
    :vehicle_length,
    :vehicle_length_unit,
    :gross_vehicle_weight,
    :gross_vehicle_weight_unit,
    :seating_capacity,
    :wheelchair_capacity,
    :ramp_manufacturer_id,
    :other_ramp_manufacturer,
    :ada_accessible
  ]

  def primary_fta_mode_type_id
    primary_fta_mode_type.try(:id)
  end

  # Override setters for primary_fta_mode_type for HABTM association
  def primary_fta_mode_type_id=(num)
    build_primary_assets_fta_mode_type(fta_mode_type_id: num, is_primary: true)
  end

  def ntd_id
    Asset.get_typed_asset(asset).asset_fleets.first.try(:ntd_id) if asset # currently temporarily looks at old asset
  end

  def reported_mileage
    mileage_updates.last.try(:current_mileage)
  end

  # link to old asset if no instance method in chain
  def method_missing(method, *args, &block)
    if !self_respond_to?(method) && acting_as.respond_to?(method)
      acting_as.send(method, *args, &block)
    elsif !self_respond_to?(method) && typed_asset.respond_to?(method)
      puts "You are calling the old asset for this method"
      Rails.logger.warn "You are calling the old asset for this method"
      typed_asset.send(method, *args, &block)
    else
      super
    end
  end

end
