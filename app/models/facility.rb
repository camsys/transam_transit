class Facility < TransamAssetRecord

  acts_as :transit_asset, as: :transit_assetible

  before_destroy { fta_mode_types.clear }

  belongs_to :esl_category
  belongs_to :leed_certification_type
  belongs_to :facility_capacity_type

  # Each facility has a set (0 or more) of facility features
  has_and_belongs_to_many   :facility_features,    :foreign_key => :transam_asset_id,    :join_table => :assets_facility_features

  # Each facility has a set (0 or more) of fta mode type. This is the primary mode
  # serviced at the facility
  has_many                  :assets_fta_mode_types,       :as => :transam_asset,    :join_table => :assets_fta_mode_types
  has_many                  :fta_mode_types,           :through => :assets_fta_mode_types

  # These associations support the separation of mode types into primary and secondary.
  has_one :primary_assets_fta_mode_type, -> { is_primary },
          class_name: 'AssetsFtaModeType', :as => :transam_asset
  has_one :primary_fta_mode_type, through: :primary_assets_fta_mode_type, source: :fta_mode_type

  has_many :secondary_assets_fta_mode_types, -> { is_not_primary }, class_name: 'AssetsFtaModeType', :as => :transam_asset,    :join_table => :assets_fta_mode_types
  has_many :secondary_fta_mode_types, through: :secondary_assets_fta_mode_types, source: :fta_mode_type,    :join_table => :assets_fta_mode_types

  belongs_to :fta_private_mode_type

  belongs_to :land_ownership_organization, :class_name => "Organization"
  belongs_to :facility_ownership_organization, :class_name => "Organization"

  # each facility has zero or more operations update events
  has_many    :facility_operations_updates, -> {where :asset_event_type_id => FacilityOperationsUpdateEvent.asset_event_type.id }, :class_name => "FacilityOperationsUpdateEvent", :as => :transam_asset

  scope :ada_accessible, -> { where(ada_accessible: true) }

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------

  validates :manufacture_year, presence: true

  validates :facility_name, presence: true
  validates :address1, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :zip, presence: true
  validates :country, presence: true
  validates :esl_category_id, presence: true
  validates :facility_size, presence: true
  validates :facility_size_unit, presence: true
  validates :section_of_larger_facility, inclusion: { in: [ true, false ] }
  validates :ada_accessible, inclusion: { in: [ nil, true, false ] }
  validates :num_structures, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :num_floors, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :num_elevators, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :num_escalators, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :num_parking_spaces_public, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :num_parking_spaces_private, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :lot_size, numericality: { greater_than: 0 }, allow_nil: true
  validates :lot_size_unit, presence: true, if: :lot_size
  #validates :primary_fta_mode_type, presence: true

  validate :primary_and_secondary_cannot_match

  def primary_and_secondary_cannot_match
    if primary_fta_mode_type != nil 
      if (primary_fta_mode_type.in? secondary_fta_mode_types) 
        errors.add(:primary_fta_mode_type, "cannot also be a secondary mode")
      end
    end
  end

  #------------------------------------------------------------------------------
  # Lists. These lists are used by derived classes to make up lists of attributes
  # that can be used for operations like full text search etc. Each derived class
  # can add their own fields to the list
  #------------------------------------------------------------------------------

  FORM_PARAMS = [
      :facility_name,
      :ntd_id,
      :address1,
      :address2,
      :city,
      :state,
      :zip,
      :county,
      :country,
      :esl_category_id,
      :facility_capacity_type_id,
      :facility_size,
      :facility_size_unit,
      :section_of_larger_facility,
      :num_structures,
      :num_floors,
      :num_elevators,
      :num_escalators,
      :num_parking_spaces_public,
      :num_parking_spaces_private,
      :lot_size,
      :lot_size_unit,
      :leed_certification_type_id,
      :ada_accessible,
      :fta_private_mode_type_id,
      :land_ownership_organization_id,
      :other_land_ownership_organization,
      :facility_ownership_organization_id,
      :other_facility_ownership_organization,
      :primary_fta_mode_type_id,
      :secondary_fta_mode_type_ids => [],
      :facility_feature_ids => []
  ]

  CLEANSABLE_FIELDS = [
      'facility_name',
      'address1',
      'address2',
      'city',
      'state',
      'zip',
      'county',
      'country'
  ]

  SEARCHABLE_FIELDS = [
      :facility_name,
      :address1,
      :address2,
      :city,
      :state,
      :zip
  ]
  def dup
    super.tap do |new_asset|
      new_asset.fta_mode_types = self.fta_mode_types
      new_asset.facility_features = self.facility_features
      new_asset.transit_asset = self.transit_asset.dup
    end
  end

  def transfer new_organization_id
    transferred_asset = super(new_organization_id)
    transferred_asset.facility_ownership_organization = nil
    transferred_asset.land_ownership_organization = nil
    transferred_asset.other_facility_ownership_organization = nil
    transferred_asset.other_land_ownership_organization = nil
    transferred_asset.pcnt_capital_responsibility = nil
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

  def latlng
    if geometry
      return [geometry.y,geometry.x] 
    else
      return [nil,nil]
    end
  end


  ######## API Serializer ##############
  def api_json(options={})
    transit_asset.api_json(options).merge(
    {
      facility_name: facility_name,
      ntd_id: ntd_id,
      address1: address1,
      address2: address2,
      city: city,
      state: state,
      zip: zip,
      county: county,
      country: country,
      esl_category: esl_category.try(:api_json),
      facility_capacity_type: facility_capacity_type.try(:api_json),
      facility_size: facility_size,
      facility_size_unit: facility_size_unit,
      section_of_larger_facility: section_of_larger_facility,
      num_structures: num_structures,
      num_floors: num_floors, 
      num_elevators: num_elevators,
      num_escalators: num_escalators,
      num_parking_spaces_public: num_parking_spaces_public,
      num_parking_spaces_private: num_parking_spaces_private,
      lot_size: lot_size,
      lot_size_unit: lot_size_unit,
      leed_certification_type: leed_certification_type.try(:api_json),
      ada_accessible: ada_accessible,
      fta_private_mode_type: fta_private_mode_type.try(:api_json),
      land_ownership_organization: land_ownership_organization.try(:api_json),
      other_land_ownership_organization: other_land_ownership_organization,
      facility_ownership_organization: facility_ownership_organization.try(:api_json),
      other_facility_ownership_organization: other_facility_ownership_organization,
      primary_fta_mode_type: primary_fta_mode_type.try(:api_json),
      secondary_fta_mode_types: secondary_fta_mode_types.map{ |f| f.try(:api_json) }, 
      facility_features: facility_features.map{ |f| f.try(:api_json) }, 


    })
  end

  ######## Inventory API Serializer ##############
  def inventory_api_json()
    transit_asset.inventory_api_json.merge(
    {
      "Characteristics^ada": ada_accessible,
      "Characteristics^facility_size": facility_size,
      "Characteristics^facility_size_unit": facility_size_unit,
      "Characteristics^section_of_larger_facility": section_of_larger_facility,
      "Characteristics^year": manufacture_year,
      "Identification & Classification^facility_name": facility_name,
      "Identification & Classification^address1": address1,
      "Identification & Classification^address2": address2,
      "Identification & Classification^city": city,
      "Identification & Classification^state": state,
      "Identification & Classification^zip": zip,
      "Identification & Classification^county": county,
      "Identification & Classification^country": country,
      "Identification & Classification^esl": { id: esl_category_id, val: esl_category.try(:name) },
      "Identification & Classification^vin": serial_number,
      # "Identification & Classification^latitude": latitude,
      # "Identification & Classification^longitude": longitude,
      # "Identification & Classification^n/s": north_south,
      # "Identification & Classification^e/w": east_west,
      "Condition^service_status": service_status_name,
    })
  end

  
    DEFAULT_FIELDS = [
      :asset_id,
      :org_name,
      :facility_name,
      :year,
      :type,
      :subtype,
      :service_status,
      :last_life_cycle_action,
      :life_cycle_action_date
  ]

  def field_library key 

    fields = {
      facility_name: {label: "Facility Name", method: :facility_name, url: nil},
      service_status: {label: "Service Status", method: :service_status_name, url: nil},
    }

    if fields[key]
      return fields[key]
    else #If not in this list, it may be part of TransitAsset
      return self.acting_as.field_library key 
    end

  end


  def rowify fields=nil
    fields ||= DEFAULT_FIELDS

    row = {}
    fields.each do |field|
      row[field] =  {label: field_library(field)[:label], data: self.send(field_library(field)[:method]), url: field_library(field)[:url]} 
    end
    return row 
  end


  #for bulk updates
  def self.bulk_updates_profile
    {
      "schema": {
        "properties": {
          "Characteristics": {
            "properties": {
              # "manufacturer": Manufacturer.schema_structure,
              # "equipment_manufacturer": {#Manufacturer.schema_structure,
              #   "type": "string",
              #   "title": "Equipment Manufacturer"
              # },
              # "model": ManufacturerModel.schema_structure,
              # "equipment_model": {#ManufacturerModel.schema_structure,
              #   "type": "string",
              #   "title": "Equipment Model"
              # },
              "year": {
                "type": "integer",
                "title": "Year of Manufacture"
              },
              # "chassis": Chassis.schema_structure,
              # "fuel_type": FuelType.schema_structure,
              # "dual_fuel_type": DualFuelType.schema_structure,
              # "length": {
              #   "type": "integer",
              #   "title": "Length (ft)"
              # },
              # "gvwr": {
              #   "type": "integer",
              #   "title": "Gross Vehicle Weight Ratio (GVWR) (lbs)"
              # },
              # "seating_cap": {
              #   "type": "integer",
              #   "title": "Seating Capacity (ambulatory)"
              # },
              # "standing_cap": {
              #   "type": "integer",
              #   "title": "Standing Capacity"
              # },
              # "wheelchair_cap": {
              #   "type": "integer",
              #   "title": "Wheelchair capacity"
              # },
              "ada": {
                "type": "boolean",
                "title": "ADA Accessible"
              },
              "facility_size": {
                "type": "integer",
                "title": "Facility Size"
              },
              "facility_size_unit": {
                "type": "string",
                "title": "Size Units"
              },
              "section_of_larger_facility": {
                "type": "boolean",
                "title": "Section of Larger Facility"
              }
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
              # "vin": {
              #   "type": "string",
              #   "title": "Vehicle Identification Number (VIN)"
              # },
              # "class": FtaAssetClass.schema_structure,
              "subtype": AssetSubtype.schema_structure,
              "esl": EslCategory.schema_structure,
              "facility_name": {
                "type": "string",
                "title": "Facility Name"
              },
              "address1": {
                "type": "string",
                "title": "Address 1"
              },
              "address2": {
                "type": "string",
                "title": "Address 2"
              },
              "city": {
                "type": "string",
                "title": "City"
              },
              "state": {
                "type": "string", #TODO
                "title": "State"
              },
              "zip": {
                "type": "string",
                "title": "ZIP Code"
              },
              "country": {
                "type": "string", # TODO
                "title": "Country"
              },
              "county": {
                "type": "string", # TODO
                "title": "County"
              },
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
                "type": "integer",
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
              # "primary_mode": { # TODO
              #   "enum": FtaServiceType.all.pluck(:name),
              #   "type": "string",
              #   "title": "Primary Mode"
              # },
              # TODO supports another mode (multiple selection allowed)
              #"service_type": FtaServiceType.schema_structure,
            },
            "title": "Operations",
            "type": "object",
          },
          "Registration & Title": {
            "properties": {
              # "plate_number": {
              #   "type": "string",
              #   "title": "Plate #"
              # },
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
              # "mileage": {
              #   "type": "number",
              #   "title": "Mileage"
              # },
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


  protected

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
