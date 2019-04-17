#------------------------------------------------------------------------------
#
# AssetEndOfServiceService
#
# Contains business logic associated with managing the disposition of assets
#
#
#------------------------------------------------------------------------------
class AssetEndOfServiceService

  # Include the fiscal year mixin
  include FiscalYear

  #------------------------------------------------------------------------------
  #
  # Disposition List
  #
  # returns a list of assets that need to be disposed by FY, type, and subtype
  #
  #------------------------------------------------------------------------------

  def list(org_id_list, fy_year=current_planning_year_year, fta_asset_category_id=nil)

    Rails.logger.debug "AssetEndOfServiceService:  list()"
    #
    if org_id_list.blank?
      Rails.logger.warn "AssetEndOfServiceService:  disposition list: Org ID cannot be null"
      return []
    end

    # Start to set up the query
    conditions  = Hash.new

    # Filter for the selected org
    conditions[:organization_id] = org_id_list

    # Filter on Replacement Year
    conditions[:scheduled_replacement_year] = fy_year

    conditions[:fta_asset_category_id] = fta_asset_category_id unless fta_asset_category_id.nil?

    TransitAsset.operational.joins(:fta_asset_category, :fta_asset_class)
        .joins('INNER JOIN asset_subtypes ON asset_subtypes.id = transam_assets.asset_subtype_id')
        .joins('INNER JOIN organizations ON organizations.id = transam_assets.organization_id')
        .joins('LEFT JOIN fta_vehicle_types ON transit_assets.fta_type_id = fta_vehicle_types.id AND transit_assets.fta_type_type="FtaVehicleType"')
        .joins('LEFT JOIN fta_equipment_types ON transit_assets.fta_type_id = fta_equipment_types.id AND transit_assets.fta_type_type="FtaEquipmentType"')
        .joins('LEFT JOIN fta_support_vehicle_types ON transit_assets.fta_type_id = fta_support_vehicle_types.id AND transit_assets.fta_type_type="FtaSupportVehicleType"')
        .joins('LEFT JOIN fta_facility_types ON transit_assets.fta_type_id = fta_facility_types.id AND transit_assets.fta_type_type="FtaFacilityType"')
        .joins('LEFT JOIN fta_track_types ON transit_assets.fta_type_id = fta_track_types.id AND transit_assets.fta_type_type="FtaTrackType"')
        .joins('LEFT JOIN fta_guideway_types ON transit_assets.fta_type_id = fta_guideway_types.id AND transit_assets.fta_type_type="FtaGuidewayType"')
        .joins('LEFT JOIN fta_power_signal_types ON transit_assets.fta_type_id = fta_power_signal_types.id AND transit_assets.fta_type_type="FtaPowerSignalType"').where(conditions)
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private

end
