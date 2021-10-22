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

    asset_type = get_assets_params[:type]

    case asset_type[:val].parameterize.underscore
      when "revenue_vehicles"
        response = RevenueVehicle.where(organization: orgs).map{ |asset|
            Rails.cache.fetch("inventory_api" + asset.object_key, nil) do
                asset.very_specific.inventory_api_json
            end
        }
      when "capital_equipment"
        response = CapitalEquipment.where(organization: orgs).map{ |asset|
            Rails.cache.fetch("inventory_api" + asset.object_key, nil) do
              asset.very_specific.inventory_api_json
            end
        }
      when "facilities"
        response = Facility.where(organization: orgs).map{ |asset|
            Rails.cache.fetch("inventory_api" + asset.object_key, nil) do
              asset.very_specific.inventory_api_json
            end
        }
      when "service_vehicles"
        response = ServiceVehicle.where(organization: orgs, service_vehiclible_type: nil).map{ |asset|
            Rails.cache.fetch("inventory_api" + asset.object_key, nil) do
              asset.very_specific.inventory_api_json
            end
        }
      else
        #return all assets
        response  = TransamAsset.where(organization: orgs).map{ |asset|
            Rails.cache.fetch("inventory_api" + asset.object_key, nil) do
              asset.very_specific.inventory_api_json
            end
        }
    end

    render status: 200, json: response
  end

  def properties
    response = {
      "schema": {
        "type": "object",
        "properties": {
          "type": {
            "enum": ["Revenue Vehicles", "Service Vehicles", "Facilities", "Capital Equipment"],#AssetType.all.pluck(:name),
            "tuple": [{id: 1, val: "Revenue Vehicles"}, {id: 2, val: "Service Vehicles"},  {id: 3, val: "Facilities"},  {id: 4, val:"Capital Equipment"}],# Asset IDs here are ARBITRARY. we made them up, because the supported 'asset type' options listed here don't correspond to any actual attribute or model.
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
    asset_type = profile_params[:type]
    case asset_type[:val].parameterize.underscore
      when "revenue_vehicles"
        response = RevenueVehicle.bulk_updates_profile
      when "capital_equipment"
        response = CapitalEquipment.bulk_updates_profile
      when "facilities"
        response = Facility.bulk_updates_profile
      when "service_vehicles"
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
          "Identification & Classification": {
            "properties": {
              "organization":{
                "type": "string",
                "title": "Organization",
                "editable": false
              },
              "asset_id":{
                "type": "string",
                "title": "Asset ID",
                "editable": false
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
          "Characteristics": {
              "properties": {
                  "manufacturer": Manufacturer.schema_structure,
                  "model": ManufacturerModel.schema_structure,
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
                  "length": {
                      "type": "integer",
                      "title": "Length"
                  },
                  "length_unit": {
                      "enum": ["foot", "inch"],
                      "tuple": [{"id": 1, "val": "foot"},{"id": 2, "val": "inch"}],
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
              "vehicle_features": VehicleFeature.schema_structure,
              "in_service_date": {
                "type": "string",
                "title": "In Service Date"
              },
              "primary_mode": FtaModeType.schema_structure.merge("title": "Primary Mode"),
              "secondary_mode": FtaModeType.schema_structure.merge("title": "Supports Another Mode"),
              "secondary_modes": FtaModeType.multiselect_schema_structure,
              "primary_service_type": FtaServiceType.schema_structure.merge("title": "Service Type (Primary Mode)"),
              "secondary_service_type": FtaServiceType.schema_structure.merge("title": "Service Type (Another Mode)"),
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
      if specific_asset.fta_asset_class.class_name == "CapitalEquipment"
        specific_asset = specific_asset.becomes(CapitalEquipment)
      end
      if can? :manage, specific_asset
        updated_attributes = {}
        lifecycle_events = {}
        attributes_with_other = {}

        #All Assets are TransamAssets
        updated_attributes.merge!((transam_asset_params update_hash).except(:condition, :service_status, :manufacturer_id, :manufacturer_name, :manufacturer_model_id, :manufacturer_model_name))
        lifecycle_events.merge!((transam_asset_params update_hash).slice(:condition, :service_status))
        attributes_with_other.merge!((transam_asset_params update_hash).slice(:manufacturer_id, :manufacturer_name, :manufacturer_model_id, :manufacturer_model_name))

        #All Assets (that use this API) are TransitAssets
        updated_attributes.merge!(transit_asset_params update_hash)
        direct_capital_responsibility = update_hash["Funding^direct_capital_responsibility"]

        if specific_asset.is_a? ServiceVehicle
          updated_attributes.merge!((service_vehicle_params update_hash).except(:mileage, :fuel_type_id, :fuel_type_name, :chassis_id, :chassis_name))
          lifecycle_events.merge!((service_vehicle_params update_hash).slice(:mileage))
          attributes_with_other.merge!((service_vehicle_params update_hash).slice(:fuel_type_id, :fuel_type_name, :chassis_id, :chassis_name))
        end

        if specific_asset.is_a? RevenueVehicle
          updated_attributes.merge!((revenue_vehicle_params update_hash).except(:fta_ownership_type_id, :fta_ownership_type_name))
          attributes_with_other.merge!((revenue_vehicle_params update_hash).slice(:fta_ownership_type_id, :fta_ownership_type_name))
        end

        if specific_asset.is_a? Facility
          updated_attributes.merge!(facility_params update_hash)
        end

        if specific_asset.is_a? CapitalEquipment
          updated_attributes.merge!(equipment_params update_hash)
          attributes_with_other.merge!((equipment_params update_hash).except(:manufacturer_id, :manufacturer_name, :manufacturer_model_id, :manufacturer_model_name))
        end

        specific_asset.update!(updated_attributes)

        lifecycle_events.keys.each do |e|
          case e
          when :condition
            ConditionUpdateEvent.create(transam_asset: specific_asset.transam_asset, assessed_rating: lifecycle_events[e], event_date: Date.today, creator: current_user)
          when :service_status
            ServiceStatusUpdateEvent.create(transam_asset: specific_asset.transam_asset, service_status_type_id: lifecycle_events[e], event_date: Date.today, creator: current_user)
          when :mileage
            MileageUpdateEvent.create(transam_asset: (specific_asset.is_a?(RevenueVehicle) ? specific_asset.service_vehicle : specific_asset), current_mileage: lifecycle_events[e], event_date: Date.today, creator: current_user)
          end
        end

        attributes_with_other.keys.each do |a|
          case a
          when :manufacturer_id
            if attributes_with_other[a]
              specific_asset.update(manufacturer_id: attributes_with_other[a], other_manufacturer: nil)
            else
              specific_asset.update(manufacturer: Manufacturer.find_by(name: "Other (Describe)", filter: specific_asset.asset_type.class_name), other_manufacturer: attributes_with_other[:manufacturer_name])
            end
          when :manufacturer_model_id
            if attributes_with_other[a]
              specific_asset.update(manufacturer_model_id: attributes_with_other[a], other_manufacturer_model: nil)
            else
              specific_asset.update(manufacturer_model: ManufacturerModel.find_by(name: "Other"), other_manufacturer_model: attributes_with_other[:manufacturer_model_name])
            end
          when :fuel_type_id
            if attributes_with_other[a]
              specific_asset.update(fuel_type_id: attributes_with_other[a], other_fuel_type: nil)
            else
              specific_asset.update(fuel_type: FuelType.find_by(name: "Other"), other_fuel_type: attributes_with_other[:fuel_type_name])
            end
          when :chassis_id
            if attributes_with_other[a]
              specific_asset.update(chassis_id: attributes_with_other[a], other_chassis: nil)
            else
              specific_asset.update(chassis: Chassis.find_by(name: "Other"), other_chassis: attributes_with_other[:chassis_name])
            end
          when :fta_ownership_type_id
            if attributes_with_other[a]
              specific_asset.update(fta_ownership_type_id: attributes_with_other[a], other_fta_ownership_type: nil)
            else
              specific_asset.update(fta_ownership_type: FtaOwnershipType.find_by(name: "Other"), other_fta_ownership_type: attributes_with_other[:fta_ownership_type_name])
            end
          end
        end

        if direct_capital_responsibility == false
          specific_asset.update(pcnt_capital_responsibility: nil)
        end

        Rails.cache.write("inventory_api" + specific_asset.object_key, specific_asset.inventory_api_json)
        return_hashes << specific_asset.inventory_api_json
      else
        render status: 500, json: {message: "no."}
        return
      end
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
    params.permit(:type => [:id, :val] )
  end

  def get_assets_params
    params.permit(:type => [:id, :val] )
  end


  def transam_asset_params update_hash
    library = {
                asset_tag: "Identification & Classification^asset_id",
                external_id: "Identification & Classification^external_id",
                asset_subtype_id: "Identification & Classification^subtype^id",
                manufacture_year: "Characteristics^year",
                manufacturer_id: "Characteristics^manufacturer^id",
                manufacturer_name: "Characteristics^manufacturer^val",
                manufacturer_model_id: "Characteristics^model^id",
                manufacturer_model_name: "Characteristics^model^val",
                purchase_cost: "Funding^cost",
                purchased_new: "Procurement & Purchase^purchased_new",
                purchase_date: "Procurement & Purchase^purchase_date",
                in_service_date: "Operations^in_service_date",
                condition: "Condition^condition",
                service_status: "Condition^service_status^id"
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
                vehicle_length_unit: "Characteristics^length_unit^val",
                seating_capacity: "Characteristics^seating_cap",
                wheelchair_capacity: "Characteristics^wheelchair_cap",
                ada_accessible: "Characteristics^ada",
                fuel_type_id: "Characteristics^fuel_type^id",
                fuel_type_name: "Characteristics^fuel_type^val",
                chassis_id: "Characteristics^chassis^id",
                chassis_name: "Characteristics^chassis^val",
                gross_vehicle_weight: "Characteristics^gvwr",
                license_plate: "Registration & Title^plate_number",
                primary_fta_mode_type_id: "Operations^primary_mode^id",
                secondary_fta_mode_type_ids: "Operations^secondary_modes",
                mileage: "Condition^mileage"
              }

    build_params_hash library, update_hash
  end

  def revenue_vehicle_params update_hash
    library = {
      standing_capacity: "Characteristics^standing_cap",
      esl_category_id: "Identification & Classification^esl^id",
      fta_funding_type_id: "Funding^funding_type^id",
      fta_ownership_type_id: "Funding^ownership_type^id",
      fta_ownership_type_name: "Funding^ownership_type^val",
      dedicated: "Operations^dedicated_asset",
      is_autonomous: "Operations^automated_autonomous_vehicle",
      vehicle_feature_ids: "Operations^vehicle_features",
      primary_fta_mode_type_id: "Operations^primary_mode^id",
      secondary_fta_mode_type_id: "Operations^secondary_mode^id",
      primary_fta_service_type_id: "Operations^primary_service_type^id",
      secondary_fta_service_type_id: "Operations^secondary_service_type^id"
    }

    build_params_hash library, update_hash
  end

  def facility_params update_hash
    library = {
      facility_name: "Identification & Classification^facility_name",
      address1: "Identification & Classification^address1",
      address2: "Identification & Classification^address2",
      city: "Identification & Classification^city",
      state: "Identification & Classification^state",
      zip: "Identification & Classification^zip",
      county: "Identification & Classification^county",
      country: "Identification & Classification^country",
      esl_category_id: "Identification & Classification^esl^id",
      facility_size:  "Characteristics^facility_size",
      facility_size_unit: "Characteristics^facility_size_unit",
      section_of_larger_facility: "Characteristics^section_of_larger_facility",
      primary_fta_mode_type_id: "Operations^primary_mode^id",
      secondary_fta_mode_type_ids: "Operations^secondary_modes"
    }

    build_params_hash library, update_hash
  end

  def equipment_params update_hash
    library = {
      other_manufacturer: "Characteristics^equipment_manufacturer",
      other_manufacturer_model: "Characteristics^equipment_model"
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
