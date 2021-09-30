class ServiceVehicle < TransamAssetRecord
  acts_as :transit_asset, as: :transit_assetible
  actable as: :service_vehiclible

  after_initialize :set_defaults

  before_destroy { fta_mode_types.clear }
  before_validation :cleanup_others

  # check policy
  after_save do
    if saved_change_to_attribute?(:fuel_type_id) && !saved_change_to_attribute?(:asset_subtype_id)
      transam_asset.send(:check_policy_rule)
      transam_asset.send(:update_asset_state)
    end
  end

  after_commit on: :update do
    Rails.logger.debug "service vehicles check fleet"

    self.check_fleet(self.previous_changes.select{|k,v| !([[nil, ''], ['',nil]].include? v)}.keys.map{|x| 'service_vehicles.'+x}, self.fta_asset_class.class_name == 'ServiceVehicle')
  end

  belongs_to :chassis
  belongs_to :fuel_type
  belongs_to :dual_fuel_type
  belongs_to :ramp_manufacturer

  # Each vehicle has a set (0 or more) of fta mode type
  has_many                  :assets_fta_mode_types,       :as => :transam_asset,    :join_table => :assets_fta_mode_types
  has_many                  :fta_mode_types,           :through => :assets_fta_mode_types

  # These associations support the separation of mode types into primary and secondary.
  has_one :primary_assets_fta_mode_type, -> { is_primary },
          class_name: 'AssetsFtaModeType', :as => :transam_asset, autosave: true, dependent: :destroy
  has_one :primary_fta_mode_type, through: :primary_assets_fta_mode_type, source: :fta_mode_type

  # These associations support the separation of mode types into primary and secondary.
  has_many :secondary_assets_fta_mode_types, -> { is_not_primary }, class_name: 'AssetsFtaModeType', :as => :transam_asset,    :join_table => :assets_fta_mode_types
  has_many :secondary_fta_mode_types, through: :secondary_assets_fta_mode_types, source: :fta_mode_type,    :join_table => :assets_fta_mode_types

  # each vehicle has zero or more operations update events
  has_many   :operations_updates, -> {where :asset_event_type_id => OperationsUpdateEvent.asset_event_type.id }, :class_name => "OperationsUpdateEvent", :as => :transam_asset

  # each vehicle has zero or more operations update events
  has_many   :vehicle_usage_updates,      -> {where :asset_event_type_id => VehicleUsageUpdateEvent.asset_event_type.id }, :class_name => "VehicleUsageUpdateEvent", :as => :transam_asset

  # each asset has zero or more storage method updates. Only for rolling stock assets.
  has_many   :storage_method_updates, -> {where :asset_event_type_id => StorageMethodUpdateEvent.asset_event_type.id }, :class_name => "StorageMethodUpdateEvent", :as => :transam_asset

  # each asset has zero or more usage codes updates. Only for vehicle assets.
  has_many   :usage_codes_updates, -> {where :asset_event_type_id => UsageCodesUpdateEvent.asset_event_type.id }, :as => :transam_asset, :class_name => "UsageCodesUpdateEvent"

  # each asset has zero or more mileage updates. Only for vehicle assets.
  has_many    :mileage_updates, -> {where :asset_event_type_id => MileageUpdateEvent.asset_event_type.id }, :as => :transam_asset, :class_name => "MileageUpdateEvent"
  accepts_nested_attributes_for :mileage_updates, :reject_if => Proc.new{|ae| ae['current_mileage'].blank? }, :allow_destroy => true

  has_many :assets_asset_fleets, :foreign_key => :transam_asset_id, :dependent => :destroy

  has_and_belongs_to_many :asset_fleets, :through => :assets_asset_fleets, :join_table => 'assets_asset_fleets', :foreign_key => :transam_asset_id

  scope :ada_accessible, -> { where(ada_accessible: true) }
  scope :non_revenue, -> { where(fta_asset_class: FtaAssetClass.find_by(code: "service_vehicle")) }

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------

  validates :manufacture_year, presence: true

  validates :manufacturer_id, presence: true
  validates :manufacturer_model_id, presence: true
  validates :fuel_type_id, presence: true
  validates :fuel_type_id, inclusion: {in: FuelType.where(code: 'OR').pluck(:id)}, if: Proc.new{|a| a.fuel_type_id.present? && a.other_fuel_type.present?}
  validates :fuel_type_id, inclusion: {in: FuelType.where(code: 'DU').pluck(:id)}, if: Proc.new{|a| a.fuel_type_id.present? && a.dual_fuel_type_id.present?}
  validates :vehicle_length, presence: true
  validates :vehicle_length, numericality: { greater_than: 0 }
  validates :vehicle_length_unit, presence: true
  validates :seating_capacity, presence: true
  validates :seating_capacity, numericality: {greater_than_or_equal_to: 0 }
  validates :wheelchair_capacity, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :ada_accessible, inclusion: { in: [ true, false ] }
  validates :chassis_id, inclusion: {in: Chassis.where(name: 'Other').pluck(:id)}, if: Proc.new{|a| a.chassis_id.present? && a.other_chassis.present?}
  validates :gross_vehicle_weight, numericality: { greater_than: 0 }, allow_nil: true
  validates :gross_vehicle_weight_unit, presence: true, if: :gross_vehicle_weight
  validates :ramp_manufacturer_id, inclusion: {in: RampManufacturer.where(name: 'Other').pluck(:id)}, if: Proc.new{|a| a.ramp_manufacturer_id.present? && a.other_ramp_manufacturer.present?}
  validate :primary_and_secondary_cannot_match, unless: Proc.new{|a| a.service_vehiclible_type == 'RevenueVehicle'}

  def primary_and_secondary_cannot_match
    if primary_fta_mode_type != nil 
      if (primary_fta_mode_type.in? secondary_fta_mode_types)
        errors.add(:primary_fta_mode_type, "cannot also be a secondary mode")
      end
    end
  end

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
    :ada_accessible,
    :primary_fta_mode_type_id,
    {mileage_updates_attributes: MileageUpdateEvent.allowable_params},
    :secondary_fta_mode_type_ids => [],
  ]

  CLEANSABLE_FIELDS = [
    'serial_number',
    'license_plate'
  ]

  SEARCHABLE_FIELDS = [
      :license_plate,
      :serial_number
  ]

  def dup
    super.tap do |new_asset|
      new_asset.assets_fta_mode_types = self.assets_fta_mode_types
      new_asset.transit_asset = self.transit_asset.dup
    end
  end

  def transfer new_organization_id
    transferred_asset = super(new_organization_id)
    transferred_asset.license_plate = nil

    transferred_asset.mileage_updates << self.mileage_updates.last.dup if self.mileage_updates.count > 0

    transferred_asset.save(validate: false)

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
    asset_fleets.first.try(:ntd_id)
  end

  def reported_mileage
    mileage_updates.last.try(:current_mileage)
  end

  def formatted_reported_mileage
    last_mileage = reported_mileage
    if last_mileage.nil? 
      return nil
    else 
      return last_mileage.to_s(:delimited)  
    end
  end
  
  def reported_mileage_date
    mileage_updates.last.try(:event_date)
  end

  def fiscal_year_mileage(fy_year=nil)
    fy_year = current_fiscal_year_year if fy_year.nil?

    last_date = start_of_fiscal_year(fy_year+1) - 1.day
    mileage_updates.where(event_date: last_date).last.try(:current_mileage)
  end

  # the last reported mileage in a FY
  def fiscal_year_last_mileage(fy_year=nil)
    fiscal_year_last_mileage_update(fy_year).try(:current_mileage)
  end

  def fiscal_year_last_mileage_update(fy_year=nil)
    fy_year = current_fiscal_year_year if fy_year.nil?

    typed_org = Organization.get_typed_organization(organization)
    start_date = typed_org.start_of_ntd_reporting_year(fy_year)

    last_date = start_date + 1.year - 1.day

    mileage_updates.where(event_date: start_date..last_date).reorder(event_date: :desc).first
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

  #####################

  def check_fleet(fields_changed=[], check_custom_fields=true)
    typed_self = TransamAsset.get_typed_asset(self)

    asset_fleets.each do |fleet|
      fleet_type = fleet.asset_fleet_type

      # only need to check on an asset which is still valid in fleet
      if self.assets_asset_fleets.find_by(asset_fleet: fleet)

        if fleet.active_assets.count == 1 && fleet.active_assets.first.object_key == self.object_key # if the last valid asset in fleet
          # check all other assets to see if they now match the last active fleet whose changes are now the fleets grouped values
          fleet.assets.where.not(id: self.id).each do |asset|
            typed_asset = TransamAsset.get_typed_asset(asset)

            is_valid = true
            fields_to_check = fleet_type.standard_group_by_fields.map{|x| x.split('.').last}
            fields_to_check += fleet_type.custom_group_by_fields if check_custom_fields
            fields_to_check.each do |field|
              if typed_asset.send(field) != typed_self.send(field) && (typed_asset.send(field).present? || typed_self.send(field).present?)
                is_valid = false
                break
              end
            end

            AssetsAssetFleet.where(transam_asset_id: asset.id, asset_fleet: fleet).update_all(active: is_valid)

          end
        else
          if (fields_changed & fleet_type.standard_group_by_fields).count > 0
            AssetsAssetFleet.where(transam_asset_id: self.id, asset_fleet: fleet).update_all(active: false)
          else # check fields in TransitAsset, TransamAsset, and custom fields
            asset_to_follow = TransamAsset.get_typed_asset(fleet.active_assets.where.not(id: self.id).first)

            fields_to_check = fleet_type.standard_group_by_fields.select{|x| x.include?('transam_assets') || x.include?('transit_assets')}.map{|x| x.split('.').last}
            fields_to_check += fleet_type.custom_group_by_fields if check_custom_fields
            new_active_value = true
            fields_to_check.each do |field|
              # puts "======="
              # puts field
              # puts asset_to_follow.send(field)
              # puts typed_self.send(field)
              # puts "=========="
              if asset_to_follow.send(field) != typed_self.send(field) && (asset_to_follow.send(field).present? || typed_self.send(field).present?)
                new_active_value = false
                break
              end
            end
            AssetsAssetFleet.where(transam_asset_id: self.id, asset_fleet: fleet).update_all(active: new_active_value)
          end
        end
      end
    end
    return true
  end

  ######## API Serializer ##############
  def api_json(options={})
    transit_asset.api_json(options).merge(
    {
      serial_number: serial_number,
      license_plate: license_plate,
      vehicle_length: vehicle_length,
      vehicle_length_unit: vehicle_length_unit,
      gross_vehicle_weight: gross_vehicle_weight,
      gross_vehicle_weight_unit: gross_vehicle_weight_unit,
      seating_capacity: seating_capacity,
      wheelchair_capacity: wheelchair_capacity,
      ada_accessible: ada_accessible,

      chassis: chassis.try(:api_json, options),
      other_chassis: other_chassis, 
      fuel_type: fuel_type.try(:api_json, options),
      dual_fuel_type: dual_fuel_type.try(:api_json, options),
      other_fuel_type: other_fuel_type,
      ramp_manufacturer: ramp_manufacturer.try(:api_json, options),
      other_ramp_manufacturer: other_ramp_manufacturer,

      primary_fta_mode_type: primary_fta_mode_type.try(:api_json, options),
      secondary_fta_mode_types: secondary_fta_mode_types.map{ |f| f.try(:api_json, options) }, 
      fta_emergency_contingency_fleet: fta_emergency_contingency_fleet

      #### TBD 
      # Mileage
      # reported_mileage: reported_mileage,
      # reported_mileage_date: reported_mileage_date
      # Condition Updates
      # Service Status Updates
      # Location updates attributes
      # dependent attributes
      # grant_purchases_attributes
      # penn_comm_type_id
      # rehab_updates_attributes

    })
  end

  def inventory_api_json
    transit_asset.inventory_api_json.merge(
    {
      "Identification & Classification^vin": serial_number,
      "Characteristics^length": vehicle_length,
      "Characteristics^length_unit": vehicle_length_unit,
      "Characteristics^seating_cap": seating_capacity,
      "Characteristics^wheelchair_cap": wheelchair_capacity,
      "Characteristics^ada": ada_accessible,
      "Characteristics^chassis": { id: chassis.try(:id), val: chassis_name },
      "Characteristics^other_chassis": other_chassis,
      "Characteristics^fuel_type": { id: fuel_type.id, val: fuel_type.try(:name)},
      "Characteristics^other_fuel_type": other_fuel_type,
      "Characteristics^dual_fuel_type": { id: dual_fuel_type_id, val: dual_fuel_type.try(:name) },
      "Characteristics^gvwr": gross_vehicle_weight,
      "Operations^primary_mode": { id: primary_assets_fta_mode_type.try(:fta_mode_type).try(:id), val: primary_assets_fta_mode_type.try(:fta_mode_type).try(:name) },
      "Operations^secondary_modes": secondary_assets_fta_mode_types.map{ |m| {id: m.try(:fta_mode_type).try(:id), val: m.try(:fta_mode_type).try(:name)} },
      "Registration & Title^plate_number": license_plate,
      "Condition^milage": formatted_reported_mileage,
      "Condition^service_status": { id: service_status.service_status_type.try(:id), val: service_status_name },
    })
  end

  #for bulk updates
  def self.bulk_updates_profile
    {
      "schema": {
        "properties": {
          "Characteristics": {
            "properties": {
              "manufacturer": Manufacturer.schema_structure,
              "manufacturer_other": {
                "type": "string",
                "title": "Manufacturer(Other)"
              },
              # "equipment_manufacturer": {#Manufacturer.schema_structure,
              #   "type": "string",
              #   "title": "Equipment Manufacturer"
              # },
              "model": ManufacturerModel.schema_structure,
              "model_other": {
                "type": "string",
                "title": "Model(Other)"
              },
              # "equipment_model": {#ManufacturerModel.schema_structure,
              #   "type": "string",
              #   "title": "Equipment Model"
              # },
              "year": {
                "type": "integer",
                "title": "Year of Manufacture"
              },
              "chassis": Chassis.schema_structure,
              "other_chassis": {
                  type: "string",
                  title: "Chassis (Other)"
              },
              "fuel_type": FuelType.schema_structure,
              "other_fuel_type": {
                  "type": "string",
                  "title": "Fuel Type (Other)"
              },
              "dual_fuel_type": DualFuelType.schema_structure,
              "length": {
                "type": "integer",
                "title": "Length"
              },
              "length_unit": {
                  "type": "string",
                  "title": "Length Units"
              },
              "gvwr": {
                "type": "integer",
                "title": "Gross Vehicle Weight Ratio (GVWR) (lbs)"
              },
              "seating_cap": {
                "type": "integer",
                "title": "Seating Capacity (ambulatory)"
              },
              "standing_cap": {
                "type": "integer",
                "title": "Standing Capacity"
              },
              "wheelchair_cap": {
                "type": "integer",
                "title": "Wheelchair capacity"
              },
              "ada": {
                "type": "boolean",
                "title": "ADA Accessible"
              },
              # "facility_size": {
              #   "type": "integer", # TODO
              #   "title": "Facility Size"
              # },
              # "size_units": {
              #   "type": "string",
              #   "title": "Size Units"
              # },
              # "section_of_larger_facility": {
              #   "type": "boolean",
              #   "title": "Section of Larger Facility"
              # }
              # "liftramp_manufacturer": RampManufacturer.schema_structure,
            },
            "title": "Characteristics",
            "type": "object",
          },
          "Identification & Classification": {
            "properties": {
              "external_id": {
                "type": "string",
                "title": "External ID"
              },
              "vin": {
                "type": "string",
                "title": "Vehicle Identification Number (VIN)"
              },
              # "class": FtaAssetClass.schema_structure,
              "type": AssetType.schema_structure,
              "subtype": AssetSubtype.schema_structure,
              # "esl": EslCategory.schema_structure,
              # "facility_name": , TODO
              # "address1": {
              #   "type": "string",
              #   "title": "Address 1"
              # },
              # "address2": {
              #   "type": "string",
              #   "title": "Address 2"
              # },
              # "city": {
              #   "type": "string",
              #   "title": "City"
              # },
              # "state": {
              #   "type": "string",
              #   "title": "State"
              # },
              # "zip_code": {
              #   "type": "string",
              #   "title": "ZIP Code"
              # },
              # "Country": {
              #   "type": "string", # TODO
              #   "title": "Country"
              # },
              # "County": {
              #   "type": "string", # TODO
              #   "title": "County"
              # },
              # "latitude": {
              #   "type": "string",
              #   "title": "Latitude"
              # },
              # "n/s": {
              #   "enum": ["North", "South"],
              #   "type": "string",
              #   "title": "N/S"
              # },
              # "longitude": {
              #   "type": "string",
              #   "title": "Longitude"
              # },
              # "e/w": {
              #   "enum": ["East", "West"],
              #   "type": "string",
              #   "title": "E/W"
              # },
            },
            "title": "Identification & Classification",
            "type": "object",
          },
          "Funding": {
            "properties": {
              "cost": {
                "type": "integer",
                "title": "Cost (Purchase)",
                "currency": true
              },
              # "funding_type": FtaFundingType.schema_structure,
              "direct_capital_responsibility": {
                "type": "boolean",
                "title": "Direct Capital Responsibility"
              },
              "percent_capital_responsibility": {
                "type": "integer",
                "title": "Percent Capital Responsibility"
              },
              # "ownership_type": FtaOwnershipType.schema_structure,
            },
            "title": "Funding",
            "type": "object",
          },
          "Procurement & Purchase": {
            "properties": {
              "purchase_date": {
                "type": "string",
                "title": "Purchase Date"
              },
              "purchased_new": {
                "type": "boolean",
                "title": "Purchased New"
              },
            },
            "title": "Procurement & Purchase",
            "type": "object",
          },
          "Operations": {
            "properties": {
              # "vehicle_features": VehicleFeature.schema_structure,
              "in_service_date": {
                "type": "string",
                "title": "In Service Date"
              },
              "primary_mode": FtaModeType.schema_structure.merge("title": "Primary Mode"),
              "secondary_modes": FtaModeType.multiselect_schema_structure,
            },
            "title": "Operations",
            "type": "object",
          },
          "Registration & Title": {
            "properties": {
              "plate_number": {
                "type": "string",
                "title": "Plate #"
              },
              "title_number": {
                "type": "string",
                "title": "Title #"
              },
            },
            "title": "Registration & Title",
            "type": "object"
          },
          "Condition": {
            "properties": {
              "mileage": {
                "type": "number",
                "title": "Mileage"
              },
              "condition": ConditionType.schema_structure,
              "service_status": ServiceStatusType.schema_structure,
            },
            "title": "Condition",
            "type": "object"
          },
        },
        "type": "object",
      },
      "uiSchema": {}
    }
  end

  #-----------------------------------------------------------------------------
  # Generate Table Data
  #-----------------------------------------------------------------------------

  def field_library key 

    fields = {
      vin: {label: "VIN", method: :serial_number, url: nil},
      service_status: {label: "Service Status", method: :service_status_name, url: nil},
      chassis: {label: "Chassis", method: :chassis_name, url: nil},
      fuel_type: {label: "Fuel Type", method: :fuel_type_name, url: nil},
      license_plate:{label: "Plate #", method: :license_plate, url: nil},
      primary_mode: {label: "Primary Mode", method: :primary_fta_mode_type_name, url: nil},
      mileage: {label: "Odometer Reading", method: :formatted_reported_mileage, url: nil}
    }

    if fields[key]
      return fields[key]
    else #If not in this list, it may be part of TransitAsset
      return self.acting_as.field_library key 
    end

  end

  # TODO: Make this a shareable Module 
  def rowify fields=nil

    #Default Fields
    fields ||= [:asset_id,
              :org_name,
              :vin,
              :manufacturer,
              :model,
              :year,
              :type,
              :subtype,
              :service_status,
              :last_life_cycle_action,
              :life_cycle_action_date]

    
    row = {}
    fields.each do |field|
      field_data = field_library(field)
      row[field] =  {label: field_data[:label], data: self.send(field_data[:method]).to_s, url: field_data[:url]} 
    end
    return row 
  end

  def service_status_name
    service_status_type.try(:name)
  end

  def service_status
    service_status_updates.order(:event_date).last
  end

  def chassis_name
    chassis.try(:name) || other_chassis
  end

  def fuel_type_name
    code = fuel_type.try(:code) 
    if code.nil? || code == "OR" #OR is "Other" fuel type
      return other_fuel_type
    else
      return fuel_type.try(:name)
    end
  end 

  def primary_fta_mode_type_name
    primary_fta_mode_type.try(:name)
  end

protected

  def set_defaults
    self.gross_vehicle_weight_unit = 'pound'
  end

  def cleanup_others
    # only has value when type is one of Other types
    if self.changes.include?("fuel_type_id") 
      if self.other_fuel_type.present?
        self.other_fuel_type = nil unless FuelType.where(code: 'OR').pluck(:id).include?(self.fuel_type_id)
      end

      if self.dual_fuel_type.present?
        self.dual_fuel_type = nil unless FuelType.where(code: 'DU').pluck(:id).include?(self.fuel_type_id)
      end
    end
    
    if self.changes.include?("chassis_id") && self.other_chassis.present?
      self.other_chassis = nil unless Chassis.where(name: 'Other').pluck(:id).include?(self.chassis_id)
    end
    
    if self.changes.include?("ramp_manufacturer_id") && self.other_ramp_manufacturer.present?
      self.other_ramp_manufacturer = nil unless RampManufacturer.where(name: 'Other').pluck(:id).include?(self.ramp_manufacturer_id)
    end

  end

end
