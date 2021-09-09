class RevenueVehicle < TransamAssetRecord
  acts_as :service_vehicle, as: :service_vehiclible

  # include BulkUpdateable

  after_initialize :set_defaults

  before_destroy do
    fta_service_types.clear
    vehicle_features.clear
  end

  before_validation   :cleanup_others

  after_commit on: :update do
    Rails.logger.debug "revenue vehicles check fleet"

    service_vehicle.check_fleet(self.previous_changes.select{|k,v| !([[nil, ''], ['',nil]].include? v)}.keys.map{|x| 'revenue_vehicles.'+x})
  end

  belongs_to :esl_category
  belongs_to :fta_funding_type
  belongs_to :fta_ownership_type

  # Each vehicle has a set (0 or more) of vehicle features
  has_and_belongs_to_many   :vehicle_features,    :foreign_key => :transam_asset_id,    :join_table => :assets_vehicle_features

  has_and_belongs_to_many   :rail_safety_features,    :foreign_key => :transam_asset_id,    :join_table => :assets_rail_safety_features

  # Each vehicle has a set (0 or more) of fta service type
  has_many                  :assets_fta_service_types,       :as => :transam_asset,    :join_table => :assets_fta_service_types
  has_many                  :fta_service_types,           :through => :assets_fta_service_types

  # These associations support the separation of service types into primary and secondary.
  has_one :primary_assets_fta_service_type, -> { is_primary },
          class_name: 'AssetsFtaServiceType', :as => :transam_asset, autosave: true, dependent: :destroy
  has_one :primary_fta_service_type, through: :primary_assets_fta_service_type, source: :fta_service_type

  # These associations support the separation of service types into primary and secondary.
  has_one :secondary_assets_fta_service_type, -> { is_not_primary },
          class_name: 'AssetsFtaServiceType', :as => :transam_asset
  has_one :secondary_fta_service_type, through: :secondary_assets_fta_service_type, source: :fta_service_type

  # These associations support the separation of mode types into primary and secondary.
  has_one :secondary_assets_fta_mode_type, -> { is_not_primary },
          class_name: 'AssetsFtaModeType', :as => :transam_asset
  has_one :secondary_fta_mode_type, through: :secondary_assets_fta_mode_type, source: :fta_mode_type

  # each RV has one NTD mileage report per FY year
  has_many :ntd_mileage_updates, -> {where :asset_event_type_id => NtdMileageUpdateEvent.asset_event_type.id }, :as => :transam_asset, :class_name => "NtdMileageUpdateEvent"
  

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------

  validates :esl_category_id, presence: true
  validates :standing_capacity, presence: true, numericality: {greater_than_or_equal_to: 0 }
  validates :fta_funding_type_id, presence: true
  validates :fta_ownership_type_id, presence: true
  validates :dedicated, inclusion: { in: [ true, false ] }
  validates :fta_ownership_type_id, inclusion: {in: FtaOwnershipType.where(name: 'Other').pluck(:id)}, if: Proc.new{|a| a.fta_ownership_type_id.present? && a.other_fta_ownership_type.present?}
  validate :primary_and_secondary_cannot_match

  def primary_and_secondary_cannot_match
    if primary_fta_mode_type && primary_fta_service_type
      if (primary_fta_mode_type == secondary_fta_mode_type) && (primary_fta_service_type == secondary_fta_service_type)
        errors.add(:primary_fta_mode_type, "and primary serivce type cannot be identical to secondary mode and service type")
      end
    end
  end

  FORM_PARAMS = [
      :esl_category_id,
      :standing_capacity,
      :fta_funding_type_id,
      :fta_ownership_type_id,
      :other_fta_ownership_type,
      :dedicated,
      :is_autonomous,
      :primary_fta_mode_type_id,
      :primary_fta_service_type_id,
      :secondary_fta_mode_type_id,
      :secondary_fta_service_type_id,
      :vehicle_feature_ids => [],
      :rail_safety_feature_ids => [],
  ]

  CLEANSABLE_FIELDS = [

  ]

  def dup
    super.tap do |new_asset|
      new_asset.assets_fta_service_types = self.assets_fta_service_types
      new_asset.vehicle_features = self.vehicle_features
      new_asset.service_vehicle = self.service_vehicle.dup
    end
  end

  def transfer new_organization_id
    transferred_asset = super(new_organization_id)
    transferred_asset.fta_ownership_type = nil
    transferred_asset.license_plate = nil

    transferred_asset.mileage_updates << self.mileage_updates.last.dup if self.mileage_updates.count > 0

    transferred_asset.save(validate: false)

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

  def fiscal_year_ntd_mileage_update(fy_year)
    ntd_mileage_updates.find_by_reporting_year(fy_year)
  end

  def fiscal_year_ntd_mileage(fy_year)
    # if no NTD mileage reported, fallback using MileageUpdate value
    fiscal_year_ntd_mileage_update(fy_year)&.ntd_report_mileage || fiscal_year_last_mileage(fy_year)
  end

  def ntd_reported_mileage
    ntd_mileage_updates.where.not(id: nil).last.try(:ntd_report_mileage)
  end
  
  def ntd_reported_mileage_date
    ntd_mileage_updates.where.not(id: nil).last.try(:event_date)
  end

  #-----------------------------------------------------------------------------
  # Generate Table Data
  #-----------------------------------------------------------------------------
  def field_library key 
    
    fields = {
      last_life_cycle_action: {label: "Last Life Cycle Action", method: :last_life_cycle_action, url: nil},
      life_cycle_action_date: {label: "Life Cycle Action Date", method: :life_cycle_action_date, url: nil},
      external_id: {label: "External ID", method: :external_id, url: nil},
      fta_asset_class: {label: "Class", method: :fta_asset_class_name, url: nil},
      vehicle_length: {label: "Length", method: :vehicle_length, url: nil},
      vehicle_length_unit: {label: "Length Unit", method: :vehicle_length_unit, url: nil},
      esl_category: {label: "ESL Category", method: :esl_name, url: nil},
      seating_capacity: {label: "Seating Capcity (Ambulatory)", method: :seating_capacity, url: nil},
      fta_funding_type: {label: "Funding Type", method: :fta_funding_type_name, url: nil},
      fta_ownership_type: {label: "Ownership Type", method: :fta_ownership_type_name, url: nil}
    }

    if fields[key]
      return fields[key]
    else #If not in this list, it may be part of ServiceVehicle
      return self.acting_as.field_library key 
    end

  end

  # TODO: Make this a shareable Module 
  def rowify fields=nil

    #Default Fields for Revenue Vehicles 
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
    
    vehicle_row = {}
    fields.each do |field|
      vehicle_row[field] =  {label: field_library(field)[:label], data: self.send(field_library(field)[:method]), url: field_library(field)[:url]} 
    end
    return vehicle_row 
  end

  #### Helpers for Revenue Vehicles 

  def esl_name
    esl_category.try(:name)
  end

  def fta_funding_type_name
    fta_funding_type.try(:name)
  end

  def fta_ownership_type_name
    if fta_ownership_type.try(:code) == "OTHR"
      return other_fta_ownership_type
    else
      return fta_ownership_type.try(:name)
    end
  end

  ######## API Serializer ##############
  def api_json(options={})
      service_vehicle.api_json(options).merge(
      {
        esl_category: esl_category.try(:api_json, options),
        standing_capacity: standing_capacity,
        fta_funding_type: fta_funding_type.try(:api_json, options),
        fta_ownership_type: fta_ownership_type.try(:api_json, options),
        other_fta_ownership_type: other_fta_ownership_type,
        dedicated: dedicated,
        primary_fta_service_type: primary_fta_service_type.try(:api_json, options),
        secondary_fta_service_type: secondary_fta_service_type.try(:api_json, options),
        secondary_fta_mode_type: secondary_fta_mode_type.try(:api_json, options),
        vehicle_features: vehicle_features.map{ |f| f.try(:api_json, options) }
      })
  end

  ######## Inventory API Serializer ##############
  def inventory_api_json(options={})
    service_vehicle.inventory_api_json.merge(
    {
      "Identification & Classification^esl": { id: esl_category_id, val: esl_category.try(:name) },
      "Characteristics^standing_cap": standing_capacity,
      "Funding^funding_type": { id: fta_funding_type.id, val: fta_funding_type_name },
      "Funding^ownership_type": { id: fta_ownership_type.id, val: fta_ownership_type_name },
      "Operations^vehicle_features": vehicle_features.map{ |f| f.try(:name) },
      "Operations^service_type": { id: primary_fta_service_type_id, val: primary_fta_service_type.try(:name) },
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
              "model": ManufacturerModel.schema_structure,
              "model_other": {
                "type": "string",
                "title": "Model(Other)"
              },
              "year": {
                "type": "integer",
                "title": "Year of Manufacture"
              },
              "chassis": Chassis.schema_structure,
              "fuel_type": FuelType.schema_structure,
              "dual_fuel_type": DualFuelType.schema_structure,
              "length": {
                "type": "integer",
                "title": "Length (ft)"
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
              "esl": EslCategory.schema_structure,
              # # "facility_name": , TODO
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
                "type": "string",
                "title": "Cost (Purchase)"
              },
              "funding_type": FtaFundingType.schema_structure,
              "direct_capital_responsibility": {
                "type": "integer",
                "title": "Direct Capital Responsibility"
              },
              "percent_capital_responsibility": {
                "type": "integer",
                "title": "Percent Capital Responsibility"
              },
              "ownership_type": FtaOwnershipType.schema_structure,
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
              "vehicle_features": VehicleFeature.schema_structure,
              "in_service_date": {
                "type": "string",
                "title": "In Service Date"
              },
              # "primary_mode": { # TODO
              #   "enum": FtaServiceType.all.pluck(:name),
              #   "type": "string",
              #   "title": "Primary Mode"
              # },
              "service_type": FtaServiceType.schema_structure,
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
              # "title_number": {
              #   "type": "string",
              #   "title": "Title #"
              # },
            },
            "title": "Registration & Title",
            "type": "object"
          },
          "Condition": {
            "properties": {
              "mileage": {
                "type": "integer",
                "title": "Mileage"
              },
              "condition": {
                "type": "string",
                "title": "Condition"
              },#ConditionType.schema_structure,
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
  
  protected

  def set_defaults
    self.dedicated = self.dedicated.nil? ? true: self.dedicated
    self.is_autonomous = self.is_autonomous.nil? ? false : self.is_autonomous
  end

  # link to old asset if no instance method in chain
  def method_missing(method, *args, &block)
    if !self_respond_to?(method) && acting_as.respond_to?(method)
      acting_as.send(method, *args, &block)
    elsif !self_respond_to?(method) && typed_asset.respond_to?(method)
      puts "You are calling the old asset #{typed_asset.object_key} for this method #{method}"
      Rails.logger.warn "You are calling the old asset for this method #{method}"
      typed_asset.send(method, *args, &block)
    else
      super
    end
  end

  def cleanup_others
    # only has value when type is one of Other types
    if self.changes.include?("fta_ownership_type_id") && self.other_fta_ownership_type.present?
      self.other_fta_ownership_type = nil unless FtaOwnershipType.where(name: 'Other').pluck(:id).include?(self.fta_ownership_type_id)
    end
  end

end
