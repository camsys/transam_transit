#------------------------------------------------------------------------------
#
# GenericVehicleInventoryLoader
#
# Class for loading generic vehicle assets.
#
#------------------------------------------------------------------------------
class TransitFacilityInventoryLoader < RollingStockLoader

  DESCRIPTION_COL          = 0
  ADDRESS_COL              = 1
  CITY_COL                 = 2
  ZIP_COL                  = 3
  LAND_OWNERSHIP_COL       = 4
  BUILDING_OWNERSHIP_COL   = 5
  LOT_SIZE_COL             = 6
  FACILITY_SIZE_COL        = 7
  SECTION_OF_FACILITY_COL  = 8
  PCNT_OPERATIONAL_COL     = 9
  FTA_FACILITY_COL         = 10
  ADA_ACCESSIBLE_COL       = 11
  FACILITY_CAPACITY_COL    = 11

  def process(asset, cells)

    asset.description = as_string(cells[DESCRIPTION_COL])
    @errors << "Description not supplied." if asset.description.blank?

    asset.address1 = as_string(cells[ADDRESS_COL])
    @errors << "Addressnot supplied." if asset.address1.blank?

    asset.city = as_string(cells[CITY_COL])
    @errors << "City not supplied." if asset.city.blank?

    asset.zip = as_string(cells[ZIP_COL])
    @errors << "Zip not supplied." if asset.zip.blank?

    # Land Ownership Type -- check both name and code
    land_ownership_type_str = as_string(cells[LAND_OWNERSHIP_COL])
    land_ownership_type = FtaOwnershipType.search(land_ownership_type_str)
    if land_ownership_type_str.nil?
      land_ownership_type = FtaOwnershipType.find_by_name("Unknown")
      @warnings << "Land Ownership Type '#{land_ownership_type_str}' not found. Defaulting to 'Unknown'."
    end
    asset.land_ownership_type = land_ownership_type

    # Building Ownership Type -- check both name and code
    building_ownership_type_str = as_string(cells[BUILDING_OWNERSHIP_COL])
    building_ownership_type = FtaOwnershipType.search(building_ownership_type_str)
    if building_ownership_type_str.nil?
      building_ownership_type = FtaOwnershipType.find_by_name("Unknown")
      @warnings << "Building Ownership Type '#{building_ownership_type_str}' not found. Defaulting to 'Unknown'."
    end
    asset.building_ownership_type = building_ownership_type

    asset.lot_size = as_float(cells[LOT_SIZE_COL])
    @errors << "Lot size not supplied." if asset.lot_size.blank?

    asset.facility_size = as_integer(cells[FACILITY_SIZE_COL])
    @errors << "Facility size not supplied." if asset.facility_size.blank?

    section_of_larger = as_string(cells[SECTION_OF_FACILITY_COL])
    if section_of_larger == 'YES'
      asset.section_of_larger_facility = true
    elsif section_of_larger == 'NO'
      asset.section_of_larger_facility = false
    else
      @errors << "Section of larger facility not supplied."
    end

    asset.pcnt_operational = as_integer(cells[PCNT_OPERATIONAL_COL])
    @errors << "Pcnt Operational not supplied." if asset.pcnt_operational.blank?

    # FTA Facility Type -- check both name and code
    fta_facility_type_str = as_string(cells[FTA_FACILITY_COL])
    fta_facility_type = FtaFacilityType.search(fta_facility_type_str)
    if fta_facility_type_str.nil?
      fta_facility_type = FtaFacilityType.find_by_name("Unknown")
      @warnings << "Fta Facility Type '#{fta_facility_type_str}' not found. Defaulting to 'Unknown'."
    end
    asset.fta_facility_type = fta_facility_type

    if asset.type_of? :transit_facility
      ada = as_string(cells[ADA_ACCESSIBLE_COL])
      if ada == 'YES'
        asset.ada_accessible_ramp = true
      elsif ada == 'NO'
        asset.ada_accessible_ramp = false
      else
        @errors << "ADA accessible ramp not supplied."
      end
    end

    if asset.type_of? :support_facility
      # Facility Capacity Type -- check both name and code
      facility_capacity_type_str = as_string(cells[FACILITY_CAPACITY_COL])
      facility_capacity_type = FacilityCapacityType.search(facility_capacity_type_str)
      if facility_capacity_type_str.nil?
        facility_capacity_type = FacilityCapacityType.find_by_name("Unknown")
        @warnings << "Facility Capacity Type '#{facility_capacity_type_str}' not found. Defaulting to 'Unknown'."
      end
      asset.facility_capacity_type = facility_capacity_type
    end

  end

  private
  def initialize
    super
  end

end
