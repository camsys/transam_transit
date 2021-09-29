class InventoryApi::V1::AssetsController < Api::ApiController

  before_action :cors_set_access_control_headers

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Allow-Headers'] = '*'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  def index
    orgs = current_user.viewable_organizations
    response  = TransamAsset.where(organization: orgs).map{ |asset| asset.very_specific.inventory_api_json }
    render status: 200, json: response
  end

  def all
    # # check for groupkey, if so return empty
    # #TransitAsset.limit(10).map{ |asset| asset.very_specific.inventory_api_json }
    # response  = 
    # RevenueVehicle.limit(10).map{ |asset| asset.very_specific.inventory_api_json }
    # .concat(
    #   CapitalEquipment.limit(10).map{ |asset| asset.very_specific.inventory_api_json }
    # ).concat(
    #   Facility.limit(10).map{ |asset| asset.very_specific.inventory_api_json }
    # )#.concat(
    # #   ServiceVehicle.limit(10).map{ |asset| asset.very_specific.inventory_api_json }
    # # )
    # render status: 200, json: response


    orgs = current_user.viewable_organizations
    response  = TransamAsset.where(organization: orgs).limit(25).map{ |asset| asset.very_specific.inventory_api_json }
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
            "enum": AssetType.all.pluck(:name),
            "tuple": AssetType.all.map{ |s| {id: s.id, val: s.name} }, # TODO filter for suppoerted asset types
            "type": "string",
            "title": "Type"
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
      when "facilities"
        response = Facility.bulk_updates_profile
      when "service_vehicle"
        response = ServiceVehicle.bulk_updates_profile
      else
        response = RevenueVehicle.bulk_updates_profile # TODO
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
              "manufacturer_other": {
                "type": "string",
                "title": "Manufacturer(Other)",
              },
              "model": ManufacturerModel.schema_structure, # TODO
              "model_other": {
                "type": "string",
                "title": "Model(Other)"
              },
              "equipment_manufacturer": {
                "type": "string",
                "title": "Equipment Manufacturer"
              },
              
              "equipment_model": {
                "type": "string",
                "title": "Equipment Model"
              },
              "year": {
                "type": "integer",
                "title": "Year of Manufacture",
                # "required": true,
              },
              "type": FtaAssetClass.schema_structure,
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
              "facility_size": {
                "type": "integer", # TODO
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
              "asset_id": {
                "type": "string",
                "title": "Asset ID"
              },
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
                "type": "string",
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
                "title": "Cost (Purchase)",
                "currency": true
              },
              "funding_type": FtaFundingType.schema_structure,
              "direct_capital_responsibility": {
                "type": "boolean",
                "title": "Direct Capital Responsibility"
              },
              "percent_capital_responsibility": {
                "type": "integer",
                "title": "% Capital Responsibility"
              },
              "ownership_type": FtaOwnershipType.schema_structure,
              "other_ownership_type": {
                "type": "string",
                "title": "Ownership Type (Other)"
              }
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
              "vehicle_features": VehicleFeature.schema_structure, # TODO
              "in_service_date": {
                "type": "string",
                "title": "In Service Date"
              },
              "primary_mode": FtaModeType.schema_structure,
              # TODO supports another mode (multiple selection allowed)              
              "service_type": FtaServiceType.schema_structure,
              "dedicated_asset": {
                "type": "boolean",
                "title": "Dedicated Asset"
              },
              "automated_autonomous_vehicle": {
                  "type": "boolean",
                  "title": "Automated or Autonomous Vehicle"
              }
              # secondary service type
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
                "type": "integer",
                "title": "Mileage"
              },
              "condition": ConditionType.schema_structure,
              "service_status": ServiceStatusType.schema_structure,
            },
            "title": "Condition",
            "type": "object"
          },
        },
        "required": ["Characteristics^year"], #TODO
        "type": "object",
      },
      "uiSchema": {}
    }
    render status: 200, json: response
  end

  def put
    return_hashes = []

    update_params.each do |update_hash|
      specific_asset = get_asset update_hash
      updated_attributes = {}

      #All Assets are TransamAssets
      updated_attributes.merge!(transam_asset_params update_hash)

      #All Assets (that use this API) are TransitAssets
      updated_attributes.merge!(transit_asset_params update_hash)

      if specific_asset.is_a? ServiceVehicle
        updated_attributes.merge!(service_vehicle_params update_hash)
      end

      if specific_asset.is_a? RevenueVehicle
        updated_attributes.merge!(revenue_vehicle_params update_hash)
      end

      if specific_asset.is_a? Facility
        updated_attributes.merge!(facility_params update_hash)
      end

      specific_asset.update!(updated_attributes)
      return_hashes << specific_asset.inventory_api_json
    end 

    render status: 200, json: return_hashes
  end

  protected

  # This Assumes that the PUT call is sending a single attribute to update
  # If that changes, this method will need to be changed.
  # Note the use of "first"
  def get_asset update_hash
    TransamAsset.find(update_hash["id"].to_i).try(:very_specific)
  end

  def update_params
    assets = request.params[:_json]
    if assets #If an array of assets is passed
      return assets 
    else #If a single asset ispassed, wrap it as an array.
      return [request.params]
    end
  end

  def profile_params
    params.permit(:type)
  end


  def transam_asset_params update_hash
    library = {
                asset_tag: "Identification & Classification^asset_id",
                external_id: "Identification & Classification^external_id",
                asset_subtype_id: "Identification & Classification^subtype^id",
                manufacture_year: "Characteristics^year",
                manufacturer_id: "Characteristics^manufacturer^id",
                manufacturer_model_id: "Characteristics^model^id",
                other_manufacturer: "Characteristics^manufacturer_other",
                other_manufacturer_model: "Characteristics^model_other",
                purchase_cost: "Funding^cost",
                purchased_new: "Procurement & Purchase^purchased_new"
              }
    build_params_hash library, update_hash
  end

  def transit_asset_params update_hash
    library = {
                fta_asset_class_id: "NEED",
                fta_type_id: "Identification & Classification^type^id",
                pcnt_capital_responsibility: "Funding^percent_capital_responsibility",
                title_number: "Registration & Title^title_number"
              }
    build_params_hash library, update_hash
  end

  def service_vehicle_params update_hash
    library = {
                serial_number: "Identification & Classification^vin",
                vehicle_length: "Characteristics^length",
                vehicle_length_unit: "Characteristics^length_unit",
                seating_capacity: "Characteristics^seating_cap",
                wheelchair_capacity: "Characteristics^wheelchair_cap",
                ada_accessible: "Characteristics^ada",
                fuel_type_id: "Characteristics^fuel_type^id",
                other_fuel_type: "Characteristics^other_fuel_type",
                dual_fuel_type_id: "Characteristics^dual_fuel_type^id",
                chassis_id: "Characteristics^chasis^id",
                gross_vehicle_weight: "Characteristics^gvwr",
                other_chassis: "Characteristics^other_chassis",
                license_plate: "Registration & Title^plate_number"
              }

    build_params_hash library, update_hash
  end

  def revenue_vehicle_params update_hash
    library = {
      standing_capacity: "Characteristics^standing_cap",
      esl_category_id: "Identification & Classification^esl^id",
      fta_funding_type_id: "Funding^funding_type^id",
      fta_ownership_type_id: "Funding^ownership_type^id",
      other_fta_ownership_type: "Funding^other_ownership_type",
      dedicated: "Operations^dedicated_asset",
      is_autonomous: "Operations^automated_autonomous_vehicle"
    }

    build_params_hash library, update_hash
  end

  def facility_params update_hash 
    library = {  
      facility_name: "Identification & Characteristics^facility_name",
      address1: "Identification & Characteristics^address1",
      address2: "Identification & Characteristics^address2",
      city: "Identification & Characteristics^city",
      state: "Identification & Characteristics^state",
      zip: "Identification & Characteristics^zip",
      county: "Identification & Characteristics^county",
      country: "Identification & Characteristics^country",
      esl_category_id: "Identification & Classification^esl^id",
      facility_size:  "Characteristics^facility_size",
      facility_size_unit: "Characteristics^facility_size_unit",
      section_of_larger_facility: "Characteristics^section_of_larger_facility"
    }

    build_params_hash library, update_hash
  end

  def build_params_hash library, update_hash
    new_params = {}
    library.each do |key, val|
      if update_hash.has_key? val
        new_params[key] =  update_hash[val]
      end
    end
    new_params 
  end

end
