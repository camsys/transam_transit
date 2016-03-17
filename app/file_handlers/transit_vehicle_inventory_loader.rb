#------------------------------------------------------------------------------
#
# GenericVehicleInventoryLoader
#
# Class for loading generic vehicle assets.
#
#------------------------------------------------------------------------------
class TransitVehicleInventoryLoader < RollingStockLoader

  MANUFACTURER_COL         = 0
  MANUFACTURER_MODEL_COL   = 1
  TITLE_OWNER_COL          = 2
  FTA_OWNERSHIP_TYPE_COL   = 3
  FTA_VEHICLE_TYPE_COL     = 4
  FUEL_TYPE_COL            = 5
  SERIAL_NUMBER_COL        = 6
  VEHICLE_LENGTH_COL       = 7

  def process(asset, cells)

    asset.manufacturer = get_manufacturer(as_string(cells[MANUFACTURER_COL]), asset)
    if asset.manufacturer.nil?
      @warnings << "Manufacturer is not defined."
      asset.manufacturer = get_manufacturer('Unknown', asset)
    end

    # Manufacturer Model
    asset.manufacturer_model = as_string(cells[MANUFACTURER_MODEL_COL])
    @errors << "Manufacturer model not supplied." if asset.manufacturer_model.blank?

    asset.title_owner = Organization.find_by(short_name: as_string(cells[TITLE_OWNER_COL]))
    @errors << "Title owner not supplied." if asset.title_owner.blank?

    # FTA Ownership Type -- check both name and code
    fta_ownership_type_str = as_string(cells[FTA_OWNERSHIP_TYPE_COL])
    fta_ownership_type = FtaOwnershipType.search(fta_ownership_type_str)
    if fta_ownership_type_str.nil?
      fta_ownership_type = FtaOwnershipType.find_by_name("Unknown")
      @warnings << "Fta Ownership Type '#{fta_ownership_type_str}' not found. Defaulting to 'Unknown'."
    end
    asset.fta_ownership_type = fta_ownership_type

    # FTA Vehicle Type -- check both name and code
    fta_vehicle_type_str = as_string(cells[FTA_VEHICLE_TYPE_COL])
    fta_vehicle_type = FtaVehicleType.search(fta_vehicle_type_str)
    if fta_vehicle_type_str.nil?
      fta_vehicle_type = FtaVehicleType.find_by_name("Unknown")
      @warnings << "Fta Vehicle Type '#{fta_vehicle_type_str}' not found. Defaulting to 'Unknown'."
    end
    asset.fta_vehicle_type = fta_vehicle_type

    # Fuel Type -- check both name and code
    fuel_type_str = as_string(cells[FUEL_TYPE_COL])
    fuel_type = FuelType.search(fuel_type_str)
    if fuel_type_str.nil?
      fuel_type = FuelType.find_by_name("Unknown")
      @warnings << "Fuel Type '#{fuel_type_str}' not found. Defaulting to 'Unknown'."
    end
    asset.fuel_type = fuel_type

    # VIN
    vin = as_string(cells[SERIAL_NUMBER_COL])
    if vin.blank?
      vin = 'XXXXXXXXXXXXXXXXX'
      @warnings << "Vehicle VIN is empty."
    end
    if vin.length != 17
      @warnings << "Vehicle VIN is invalid. Should be 17 characters."
    end
    asset.serial_number = vin

    # Vehicle Length
    vehicle_length = as_integer(cells[VEHICLE_LENGTH_COL])
    if asset.type_of? :vehicle
      if vehicle_length == 0
        vehicle_length = estimate_vehicle_length(asset)
        @warnings << "Vehicle Length not set. Estimating from asset subtype."
      end
      asset.vehicle_length = vehicle_length
    end

  end

  private
  def initialize
    super
  end

end
