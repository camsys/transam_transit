class InventoryApi::V1::AssetsController < ApplicationController

  before_action :cors_set_access_control_headers

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Allow-Headers'] = '*'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  def index
    response  = TransitAsset.limit(10).map{ |asset| asset.very_specific.inventory_api_json }
    render status: 200, json: response
  end

  def all
    # check for groupkey, if so return empty
    response  = TransitAsset.limit(100).map{ |asset| asset.very_specific.inventory_api_json }
    render status: 200, json: response
  end

  def properties
    response = {
      "schema": {
        "type": "object", 
        "properties": { 
          # "parent_id": { 
          #   "title": "Parent Asset ID", 
          #   "type": "number" 
          # }, 
          "type": { 
            "title": "Asset Type", 
            "type": "string", 
            "enum": ["Revenue Vehicle", "Capital Equipment", "Service Vehicles", "Facilities"]
          }
        }
      }, 
      "uiSchema": {} 
    }
    render status: 200, json: response
  end

  def post_profile
    puts profile_params.ai
    asset_type = profile_params[:type]
    case asset_type.parameterize.underscore
      when "revenue_vehicle"
        response = RevenueVehicle.bulk_updates_profile
      when "equipment"
        response = CapitalEquipment.bulk_updates_profile
      else
        response = RevenueVehicle.bulk_updates_profile
    end
    render status: 200, json: response
  end

  def get_profile
    response = {
      "schema": {
        "properties": {
          "Characteristics": {
            "properties": {
              "manufacturer": Manufacturer.schema_structure,
              "equipment_manufacturer": {#Manufacturer.schema_structure, # TODO
                "type": "string",
                "title": "Equipment Manufacturer"
              },
              "model": ManufacturerModel.schema_structure,
              "equipment_model": {#ManufacturerModel.schema_structure, # TODO
                "type": "string",
                "title": "Equipment Model"
              },
              "year": {
                "type": "integer",
                "title": "Year of Manufacture"
              },
              "chasis": Chassis.schema_structure,
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
              "facility_size": {
                "type": "integer", # TODO
                "title": "Facility Size"
              },
              "size_units": {
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
              "vin": {
                "type": "string",
                "title": "Vehicle Identification Number (VIN)"
              },
              "classification": FtaAssetClass.schema_structure,
              "subtype": AssetSubtype.schema_structure,
              "esl": EslCategory.schema_structure,
              # "facility_name": , TODO
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
                "type": "string",
                "title": "State"
              },
              "zip_code": {
                "type": "string",
                "title": "ZIP Code"
              },
              "Country": {
                "type": "string", # TODO
                "title": "Country"
              },
              "County": {
                "type": "string", # TODO
                "title": "County"
              },
              "latitude": {
                "type": "string",
                "title": "Latitude"
              },
              "n/s": {
                "enum": ["North", "South"],
                "type": "string",
                "title": "N/S"
              },
              "longitude": {
                "type": "string",
                "title": "Longitude"
              },
              "e/w": {
                "enum": ["East", "West"],
                "type": "string",
                "title": "E/W"
              },
            },
            "title": "Identification & Classification",
            "type": "object",
          },
          "Funding": {
            "properties": {
              "cost": {
                "type": "integer",
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
              "primary_mode": { # TODO
                "enum": FtaServiceType.all.pluck(:name),
                "type": "string",
                "title": "Primary Mode"
              },
              # TODO supports another mode (multiple selection allowed)              "service_type": FtaServiceType.schema_structure,
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
    render status: 200, json: response
  end

  def put
    get_asset

    updated_attributes = {}

    if @specific_asset.is_a? ServiceVehicle
      updated_attributes.merge!(service_vehicle_params)
    end

    if @specific_asset.is_a? RevenueVehicle
      updated_attributes.merge!(revenue_vehicle_params)
    end

    @specific_asset.update!(updated_attributes)
    render status: 200, json: @specific_asset.inventory_api_json
  end

  protected

  # This Assumes that the PUT call is sending a single attribute to update
  # If that changes, this method will need to be changed.
  # Note the use of "first"
  def get_asset
    @specific_asset = TransamAsset.find(update_params["id"].to_i).try(:very_specific)
  end

  def update_params
    request.params[:_json].first
  end

  def profile_params
    params.permit(:type)
  end


  def transam_asset_params
    {organization_id: update_params[:organization_id]}
  end

  def service_vehicle_params
    library = {
                serial_number: "Identification & Classification^vin",
                vehicle_length: "Characteristics^length",
                seating_capacity: "Characteristics^seating_cap",
                wheelchair_capacity: "Characteristics^wheelchair_cap",
                ada_accessible: "Characteristics^ada"
              }

    new_params = {}
    library.each do |key, val|
      if update_params[val]
        new_params[key] =  update_params[val]
      end
    end
    new_params 
  end

  def revenue_vehicle_params
    library = {
      standing_capacity: "Characteristics^standing_cap"
    }

    new_params = {}
    library.each do |key, val|
      if update_params[val]
        new_params[key] =  update_params[val]
      end
    end
    new_params 
  end

end
