class CapitalEquipment < TransitAsset

  default_scope { where(fta_asset_class: FtaAssetClass.where(class_name: 'CapitalEquipment')) }

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------

  validates :manufacture_year, presence: true
  validates :quantity, presence: true
  validates :quantity_unit, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :description, presence: true
  validates :other_manufacturer, presence: true
  validates :other_manufacturer_model, presence: true

  FORM_PARAMS = [
    :serial_number_strings
  ]

  def serial_number_strings
    serial_numbers.pluck(:identification).join("\n")
  end

  def serial_number_strings=(strings)
    # HACK: Temporary use of big hammer while developing
    serial_numbers.destroy_all
    strings.split("\n").each do |sn|
      SerialNumber.create(identifiable_type: 'TransamAsset',
                          identifiable_id: self.id,
                          identification: sn)
    end
  end

  ######## Inventory API Serializer ##############
  def inventory_api_json()
    super.merge({
      "Characteristics^equipment_manufacturer": other_manufacturer,
      "Characteristics^equipment_model": other_manufacturer_model,
    })
  end

  #-----------------------------------------------------------------------------
  # Generate Table Data
  #-----------------------------------------------------------------------------

  def field_library key 
    
    fields = {
      service_status: {label: "Service Status", method: :service_status_name, url: nil},
    }

    if fields[key]
      return fields[key]
    else #If not in this list, it may be part of TransitAsset
      return super key 
    end

  end

  # TODO: Make this a shareable Module 
  def rowify fields=nil

    #Default Fields
    fields ||= [:asset_id,
              :org_name,
              :description,
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
      row[field] =  {label: field_data[:label], data: self.send(field_data[:method]), url: field_data[:url]} 
    end
    return row 
  end

  def service_status_name
    service_status.try(:service_status_type).try(:name)
  end

  def service_status
    service_status_updates.order(:event_date).last
  end

  def self.bulk_updates_profile
    {
      "schema": {
        "properties": {
          "Characteristics": {
            "organization_id":{
              "type": "string",
              "title": "Organization",
              "editable":false
            },
            "asset_id":{
              "type": "string",
              "title": "Asset ID",
              "editable":false
            },
            "properties": {
              "equipment_manufacturer": {#Manufacturer.schema_structure,
                "type": "string",
                "title": "Equipment Manufacturer"
              },
              "equipment_model": {#ManufacturerModel.schema_structure,
                "type": "string",
                "title": "Equipment Model"
              },
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
              # "ada": {
              #   "type": "boolean",
              #   "title": "ADA Accessible"
              # },
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
              # "classification": FtaAssetClass.schema_structure,
              "type": FtaEquipmentType.schema_structure,
              "subtype": AssetSubtype.schema_structure,
              "esl": EslCategory.schema_structure,
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
              # "primary_mode": { # TODO
              #   "enum": FtaServiceType.all.pluck(:name),
              #   "type": "string",
              #   "title": "Primary Mode"
              # },
              # "service_type": FtaServiceType.schema_structure,
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
                "condition": {
                    "type": "number",
                    "title": "Assessed Rating"
                },
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

end
