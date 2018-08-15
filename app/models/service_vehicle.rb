class ServiceVehicle < TransamAssetRecord
  acts_as :transit_asset, as: :transit_assetible
  actable as: :service_vehiclible

  before_destroy { fta_mode_types.clear }
  after_save :check_fleet

  belongs_to :chassis
  belongs_to :fuel_type
  belongs_to :dual_fuel_type
  belongs_to :ramp_manufacturer

  # Each vehicle has a set (0 or more) of fta mode type
  has_many                  :assets_fta_mode_types,       :foreign_key => :transam_asset_id,    :join_table => :assets_fta_mode_types
  has_and_belongs_to_many   :fta_mode_types,              :foreign_key => :transam_asset_id,    :join_table => :assets_fta_mode_types

  # These associations support the separation of mode types into primary and secondary.
  has_one :primary_assets_fta_mode_type, -> { is_primary },
          class_name: 'AssetsFtaModeType', :foreign_key => :transam_asset_id
  has_one :primary_fta_mode_type, through: :primary_assets_fta_mode_type, source: :fta_mode_type

  # These associations support the separation of mode types into primary and secondary.
  has_many :secondary_assets_fta_mode_types, -> { is_not_primary }, class_name: 'AssetsFtaModeType', :foreign_key => :transam_asset_id,    :join_table => :assets_fta_service_types
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

  has_many :assets_asset_fleets, :foreign_key => :transam_asset_id

  has_and_belongs_to_many :asset_fleets, :through => :assets_asset_fleets, :join_table => 'assets_asset_fleets', :foreign_key => :transam_asset_id


  scope :ada_accessible, -> { where(ada_accessible: true) }

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------

  validates :serial_numbers, length: {is: 1}
  validates :manufacturer_id, presence: true
  validates :manufacturer_model_id, presence: true
  validates :fuel_type_id, presence: true
  validates :fuel_type_id, inclusion: {in: FuelType.where(code: 'OR').pluck(:id)}, if: Proc.new{|a| a.other_fuel_type.present?}
  validates :fuel_type_id, inclusion: {in: FuelType.where(code: 'DU').pluck(:id)}, if: Proc.new{|a| a.dual_fuel_type_id.present?}
  validates :vehicle_length, presence: true
  validates :vehicle_length, numericality: { greater_than: 0 }
  validates :vehicle_length_unit, presence: true
  validates :seating_capacity, presence: true
  validates :seating_capacity, numericality: {greater_than_or_equal_to: 0 }
  validates :wheelchair_capacity, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :ada_accessible, inclusion: { in: [ true, false ] }
  validates :chassis_id, inclusion: {in: Chassis.where(name: 'Other').pluck(:id)}, if: Proc.new{|a| a.other_chassis.present?}
  validates :gross_vehicle_weight, numericality: { greater_than: 0 }, allow_nil: true
  validates :gross_vehicle_weight_unit, presence: true, if: :gross_vehicle_weight
  validates :ramp_manufacturer_id, inclusion: {in: RampManufacturer.where(name: 'Other').pluck(:id)}, if: Proc.new{|a| a.other_ramp_manufacturer.present?}
  validates :primary_fta_service_type, presence: true
  validates :primary_fta_mode_type, presence: true

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

  CLEANSABLE_FIELDS = [
    'serial_number',
    'license_plate'
  ]

  def dup
    super.tap do |new_asset|
      new_asset.fta_mode_types = self.fta_mode_types
      new_asset.transit_asset = self.transit_asset.dup
    end
  end

  def transfer new_organization_id
    transferred_asset = super(new_organization_id)
    transferred_asset.license_plate = nil
    transferred_asset.save(validate: false)

    transferred_asset.mileage_updates << self.mileage_updates.last.dup if self.mileage_updates.count > 0

    return transferred_asset
  end

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

  def fiscal_year_mileage(fy_year=nil)
    fy_year = current_fiscal_year_year if fy_year.nil?

    last_date = start_of_fiscal_year(fy_year+1) - 1.day
    mileage_updates.where(event_date: last_date).last.try(:current_mileage)
  end

  def expected_useful_miles
    # TODO might need to update this for used miles.
    policy_analyzer.get_min_service_life_miles
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

  def serial_number
    serial_numbers.first.try(:identification)
  end

  def serial_number=(value)
    new_sn = self.serial_numbers.first_or_create do |sn|
      sn.identifiable_type = self.class.name
      sn.identifiable_id = self.id
    end
    new_sn.identification = value
    new_sn.save
  end

  def get_default_table_headers()
    ["Asset ID", "Organization", "VIN", "Manufacturer", "Model", "Year", "Class",
     "Type", "Status", "ESL", "Last Life Cycle Action", "Life Cycle Action Date"]
  end

  def get_all_table_headers()
    ["Asset ID", "Organization", "VIN", "Manufacturer", "Model", "Year", "Class", "Type", "Status", "ESL",
     "Last Life Cycle Action", "Life Cycle Action Date", "External ID", "Subtype", "ESL Category", "Chassis",
     "Fuel Type", "Funding Program (largest %)", "Operator", "Plate #", "Primary Mode", "Direct Capital Responsibility",
     "Capital Responsibility %", "Asset Group", "Service Life - Current", "TERM Condition", "TERM Rating", "NTD ID",
     "Date of Condition Assessment", "Odometer Reading", "Date of Odometer Reading", "Replace / Rehab Policy (ESL)",
     "TAM Policy (ULB)", "ESL - Adjusted", "ULB - Adjusted", "Rebuild / Rehab Type", "Date of Rebuild / Rehab", "Location",
     "Current Book Value", "Replacement Status", "Replacement Policy Year", "Replacement Actual Year", "Scheduled Replacement Cost"]
  end

protected

  def check_fleet
    asset_fleets.each do |fleet|
      fleet_type = fleet.asset_fleet_type

      # only need to check on an asset which is still valid in fleet
      if self.assets_asset_fleets.find_by(asset_fleet: fleet).active

        if fleet.active_assets.count == 1 && fleet.active_assets.first.object_key == self.object_key # if the last valid asset in fleet
          # check all other assets to see if they now match the last active fleet whose changes are now the fleets grouped values
          fleet.assets.where.not(id: self.id).each do |asset|
            typed_asset = Asset.get_typed_asset(asset)
            if asset.attributes.slice(*fleet_type.standard_group_by_fields) == self.attributes.slice(*fleet_type.standard_group_by_fields)
              is_valid = true
              fleet_type.custom_group_by_fields.each do |field|
                if typed_asset.send(field) != self.send(field)
                  is_valid = false
                  break
                end
              end

              AssetsAssetFleet.find_by(asset: asset, asset_fleet: fleet).update(active: is_valid)
            end
          end
        else
          if (self.previous_changes.keys & fleet_type.standard_group_by_fields).count > 0
            AssetsAssetFleet.find_by(asset: self, asset_fleet: fleet).update(active: false)
          else # check custom fields
            asset_to_follow = Asset.get_typed_asset(fleet.active_assets.where.not(id: self.id).first)

            fleet_type.custom_group_by_fields.each do |field|
              if asset_to_follow.send(field) != self.send(field)
                AssetsAssetFleet.find_by(asset: self, asset_fleet: fleet).update(active: false)
                break
              end
            end
          end
        end
      end
    end

    return true
  end

end
