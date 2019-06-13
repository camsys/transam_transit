class AddRebuiltYearToRevenueVehicleAssetFleetTypeGroups < ActiveRecord::DataMigration
  def up
    rv_fleet_type = AssetFleetType.find_by_class_name 'RevenueVehicle'
    if rv_fleet_type
      rv_fleet_type.update(groups: "transit_assets.fta_type_type, transit_assets.fta_type_id,revenue_vehicles.dedicated,transam_assets.manufacturer_id,transam_assets.other_manufacturer,transam_assets.manufacturer_model_id,transam_assets.manufacture_year,transam_assets.rebuilt_year,service_vehicles.fuel_type_id,service_vehicles.dual_fuel_type_id,revenue_vehicles.fta_ownership_type_id,revenue_vehicles.fta_funding_type_id")
    end
  end
end