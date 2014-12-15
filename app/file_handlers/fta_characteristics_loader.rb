#------------------------------------------------------------------------------
#
# FtaCharacteristicsLoader
#
# Loads FTA Vehicle Characateristics
#
#------------------------------------------------------------------------------
class FtaCharacteristicsLoader < InventoryLoader
  
  FTA_MODES_COL                       = 0
  FTA_SERVICE_TYPES_COL               = 1
  FTA_OWNERSHIP_TYPE_COL              = 2
  FTA_FUNDING_TYPE_COL                = 3
  FTA_FUNDING_SOURCE_CODE_COL         = 4
  STATE_FUNDING_SOURCE_CODE_COL       = 5
  FTA_VEHICLE_TYPE_COL                = 6
  PCNT_FEDERAL_FUNDING_COL            = 7
  FTA_ADA_LIFT_COL                    = 8
  FTA_ADA_RAMP_COL                    = 9
  FTA_EMERGENCY_CONTINGENCY_FLEET_COL = 10
  FEDERAL_GRANT_NUMBER_COL            = 11
    
  def process(asset, cells)
               
    # FTA Modes                      
    vals = as_string(cells[FTA_MODES_COL])  
    if ! vals.blank?
      vals.split(",").each do |val|
        val.strip!    
        x = FtaModeType.search(val)   
        if x.nil?
          @warnings << "FTA Mode Type '#{val}' not recognized. Skipping."
        else
          asset.fta_mode_types << x          
        end                    
      end
    else
      @warnings << "FTA Mode Type must be set."
    end
    
    # FTA Service Types            
    vals = as_string(cells[FTA_SERVICE_TYPES_COL])  
    if ! vals.blank?
      vals.split(",").each do |val|
        val.strip!    
        x = FtaServiceType.search(val) 
        if x.nil?
          @warnings << "FTA Service Type '#{val}' not recognized. Skipping."
        else
          asset.fta_service_types << x          
        end                    
      end
    else
      @warnings << "FTA Service Type must be set."
    end
            
    # FTA Ownership Type
    val = as_string(cells[FTA_OWNERSHIP_TYPE_COL])
    asset.fta_ownership_type = FtaOwnershipType.search(val)
    if asset.fta_ownership_type.nil?
      asset.fta_ownership_type = FtaOwnershipType.find_by_name("Unknown")
      @warnings << "FTA Ownership Type not set."
    end

    # Fta Funding Type -- this is currently coded as CODE-NAME eg OF-Other Federal Funds
    val = as_string(cells[FTA_FUNDING_TYPE_COL])
    val = val.split('-').first unless val.blank?
    asset.fta_funding_type = FtaFundingType.search(val)
    if asset.fta_funding_type.nil?
      asset.fta_funding_type = FtaFundingType.find_by_name("Unknown")
      @warnings << "FTA Funding Type not set."
    end
  
    # FTA Funding Source       
    val = as_string(cells[FTA_FUNDING_SOURCE_CODE_COL])
    asset.fta_funding_source_type = FtaFundingSourceType.search(val)
    if asset.fta_funding_source_type.nil?
      asset.fta_funding_source_type = FtaFundingSourceType.find_by_name("Unknown")
      @warnings << "FTA Funding Source Type not set."
    end

    # FTA Vehicle Type
    val = as_string(cells[FTA_VEHICLE_TYPE_COL])
    asset.fta_vehicle_type = FtaVehicleType.search(val)
    if asset.fta_vehicle_type.nil?
      asset.fta_vehicle_type = FtaVehicleType.find_by_name("Unknown")
      @warnings << "FTA Vehicle Type not set."
    end
                
    # PCNT Federal Funding                
    asset.pcnt_federal_funding = as_integer(cells[PCNT_FEDERAL_FUNDING_COL])

    # ADA Accessible Lift
    asset.ada_accessible_lift = as_boolean(cells[FTA_ADA_LIFT_COL])           

    # ADA Accessible Ramp
    asset.ada_accessible_ramp = as_boolean(cells[FTA_ADA_RAMP_COL])           

    # FTA Emergency Fleet
    asset.fta_emergency_contingency_fleet = as_boolean(cells[FTA_EMERGENCY_CONTINGENCY_FLEET_COL])
                             
  end
  
  private
  def initialize
    super
  end
  
end