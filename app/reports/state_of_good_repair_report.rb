#------------------------------------------------------------------------------
#
# State of Good Repair Report
#
# Generates a report of assets representing the CURRENT state of an agency's
# assets
#
#------------------------------------------------------------------------------
class StateOfGoodRepairReport < AbstractAssetReport

  private
  def initialize(attributes={})
    # No Service for this report, unlike other AssetReports.  ALL assets under review
    # @service = ####
    super(attributes)
  end

  # Override standard method (via service), get all undisposed assets
  def get_assets(organization_id_list, fiscal_year, asset_type_id=nil, asset_subtype_id=nil )
    TransitAsset.operational.joins(:fta_asset_category, :fta_asset_class)
        .joins('INNER JOIN asset_subtypes ON asset_subtypes.id = transam_assets.asset_subtype_id')
        .joins('INNER JOIN organizations ON organizations.id = transam_assets.organization_id')
        .joins('LEFT JOIN fta_vehicle_types ON transit_assets.fta_type_id = fta_vehicle_types.id AND transit_assets.fta_type_type="FtaVehicleType"')
        .joins('LEFT JOIN fta_equipment_types ON transit_assets.fta_type_id = fta_equipment_types.id AND transit_assets.fta_type_type="FtaEquipmentType"')
        .joins('LEFT JOIN fta_support_vehicle_types ON transit_assets.fta_type_id = fta_support_vehicle_types.id AND transit_assets.fta_type_type="FtaSupportVehicleType"')
        .joins('LEFT JOIN fta_facility_types ON transit_assets.fta_type_id = fta_facility_types.id AND transit_assets.fta_type_type="FtaFacilityType"')
        .joins('LEFT JOIN fta_track_types ON transit_assets.fta_type_id = fta_track_types.id AND transit_assets.fta_type_type="FtaTrackType"')
        .joins('LEFT JOIN fta_guideway_types ON transit_assets.fta_type_id = fta_guideway_types.id AND transit_assets.fta_type_type="FtaGuidewayType"')
        .joins('LEFT JOIN fta_power_signal_types ON transit_assets.fta_type_id = fta_power_signal_types.id AND transit_assets.fta_type_type="FtaPowerSignalType"').where(organization_id: organization_id_list)
  end

  def set_defaults
    if @fy_year
      @fy_year = @fy_year.to_i
    else
      @fy_year = current_fiscal_year_year
    end
  end
end
