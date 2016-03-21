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
  STATE_COL                = 3
  ZIP_COL                  = 4
  LAND_OWNERSHIP_COL       = 5
  BUILDING_OWNERSHIP_COL   = 6
  LOT_SIZE_COL             = 7
  FACILITY_SIZE_COL        = 8
  SECTION_OF_FACILITY_COL  = 9
  PCNT_OPERATIONAL_COL     = 10
  FTA_FACILITY_COL         = 11
  ADA_ACCESSIBLE_COL       = 12
  FACILITY_CAPACITY_COL    = 12

  def process(asset, cells)

    asset.description = as_string(cells[DESCRIPTION_COL])
    @errors << "Description not supplied." if asset.description.blank?

    asset.address1 = as_string(cells[ADDRESS_COL])
    @errors << "Address not supplied." if asset.address1.blank?

    asset.city = as_string(cells[CITY_COL])
    @errors << "City not supplied." if asset.city.blank?

    asset.state = as_string(cells[CITY_COL])
    @errors << "State not supplied." if asset.state.blank?

    asset.zip = as_string(cells[ZIP_COL])
    @errors << "Zip not supplied." if asset.zip.blank?

    # Land Ownership Type -- check both name and code
    land_ownership_type = FtaOwnershipType.search(as_string(cells[LAND_OWNERSHIP_COL]))
    if land_ownership_type.nil?
      @warnings << "Land Ownership Type not found."
    else
      asset.land_ownership_type = land_ownership_type
    end


    # Building Ownership Type -- check both name and code
    building_ownership_type = FtaOwnershipType.search(as_string(cells[BUILDING_OWNERSHIP_COL]))
    if building_ownership_type.nil?
      @warnings << "Building Ownership Type not found."
    else
      asset.building_ownership_type = building_ownership_type
    end

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
      @warnings << "Section of larger facility not supplied."
    end

    asset.pcnt_operational = as_integer(cells[PCNT_OPERATIONAL_COL])
    @errors << "Pcnt Operational not supplied." if asset.pcnt_operational.blank?

    # FTA Facility Type -- check both name and code
    fta_facility_type = FtaFacilityType.search(as_string(cells[FTA_FACILITY_COL]))
    if fta_facility_type.nil?
      @warnings << "Fta Facility Type not found."
    else
      asset.fta_facility_type = fta_facility_type
    end

    if asset.type_of? :transit_facility
      ada = as_string(cells[ADA_ACCESSIBLE_COL])
      if ada == 'YES'
        asset.ada_accessible_ramp = true
      elsif ada == 'NO'
        asset.ada_accessible_ramp = false
      else
        @warnings << "ADA accessible ramp not supplied."
      end
    end

    if asset.type_of? :support_facility
      # Facility Capacity Type -- check both name and code
      facility_capacity_type = FacilityCapacityType.search(as_string(cells[FACILITY_CAPACITY_COL]))
      if facility_capacity_type.nil?
        facility_capacity_type = FacilityCapacityType.find_by_name("Unknown")
        @warnings << "Facility Capacity Type not found."
      else
        asset.facility_capacity_type = facility_capacity_type
      end
    end

  end

  private
  def initialize
    super
  end

end
