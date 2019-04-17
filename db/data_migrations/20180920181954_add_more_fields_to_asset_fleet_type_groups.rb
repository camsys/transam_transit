class AddMoreFieldsToAssetFleetTypeGroups < ActiveRecord::DataMigration
  def up
    # put your code here
    rv_fleet_type = AssetFleetType.find_by(class_name: 'RevenueVehicle')
    if rv_fleet_type
      groups = "transit_assets.fta_type_type, transit_assets.fta_type_id,revenue_vehicles.dedicated,transam_assets.manufacturer_id,transam_assets.other_manufacturer, transam_assets.manufacture_year,transam_assets.manufacturer_model_id, transam_assets.other_manufacturer_model, service_vehicles.fuel_type_id,service_vehicles.dual_fuel_type_id, service_vehicles.other_fuel_type, revenue_vehicles.fta_ownership_type_id, revenue_vehicles.other_fta_ownership_type, revenue_vehicles.fta_funding_type_id, service_vehicles.vehicle_length,service_vehicles.seating_capacity,revenue_vehicles.standing_capacity"
      rv_fleet_type.update!(groups: groups)
    end
  end
end