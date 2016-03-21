#------------------------------------------------------------------------------
#
# GenericVehicleInventoryLoader
#
# Class for loading generic vehicle assets.
#
#------------------------------------------------------------------------------
class TransitRailInventoryLoader < RollingStockLoader

  MANUFACTURER_COL         = 0
  MANUFACTURER_MODEL_COL   = 1
  MANUFACTURE_YEAR_COL     = 2
  TITLE_OWNER_COL          = 3
  FTA_OWNERSHIP_TYPE_COL   = 4
  FTA_VEHICLE_TYPE_COL     = 5
  VEHICLE_LENGTH_COL       = 6

  def process(asset, cells)

    manufacturer = get_manufacturer(as_string(cells[MANUFACTURER_COL]), asset)
    if manufacturer.nil?
      @warnings << "Manufacturer is not defined."
    else
      asset.manufacturer = manufacturer
    end

    # Manufacturer Model
    asset.manufacturer_model = as_string(cells[MANUFACTURER_MODEL_COL])
    @errors << "Manufacturer model not supplied." if asset.manufacturer_model.blank?

    # Manufacture Year
    manufacture_year = as_year(cells[MANUFACTURE_YEAR_COL])
    if manufacture_year.blank?
      @warnings << "Manufacture year not supplied."
    else
      asset.manufacture_year = manufacture_year
    end

    title_owner = Organization.find_by(name: as_string(cells[TITLE_OWNER_COL]))
    if title_owner.nil?
      @warnings << "Title owner not supplied."
    else
      asset.title_owner = title_owner
    end

    # FTA Ownership Type -- check both name and code
    fta_ownership_type = FtaOwnershipType.search(as_string(cells[FTA_OWNERSHIP_TYPE_COL]))
    if fta_ownership_type.nil?
      @warnings << "Fta Ownership Type not found."
    else
      asset.fta_ownership_type = fta_ownership_type
    end

    # FTA Vehicle Type -- check both name and code
    fta_vehicle_type = FtaVehicleType.search(as_string(cells[FTA_VEHICLE_TYPE_COL]))
    if fta_vehicle_type.nil?
      @warnings << "Fta Vehicle Type not found."
    else
      asset.fta_vehicle_type = fta_vehicle_type
    end

    # Vehicle Length
    vehicle_length = as_integer(cells[VEHICLE_LENGTH_COL])
    if asset.type_of? :rail_car
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
