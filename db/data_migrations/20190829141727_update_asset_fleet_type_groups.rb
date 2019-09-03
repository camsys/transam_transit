class UpdateAssetFleetTypeGroups < ActiveRecord::DataMigration
  def up
    AssetFleetType.find_by(class_name: 'RevenueVehicle').update!( groups:
                                                                      "transit_assets.fta_type_type, transit_assets.fta_type_id,revenue_vehicles.dedicated,transam_assets.manufacturer_id,transam_assets.other_manufacturer,transam_assets.manufacturer_model_id,transam_assets.other_manufacturer_model,transam_assets.manufacture_year,transam_assets.rebuilt_year,service_vehicles.fuel_type_id,service_vehicles.dual_fuel_type_id,revenue_vehicles.fta_ownership_type_id,revenue_vehicles.fta_funding_type_id,service_vehicles.vehicle_length,service_vehicles.vehicle_length_unit,service_vehicles.seating_capacity,revenue_vehicles.standing_capacity")
  end
end