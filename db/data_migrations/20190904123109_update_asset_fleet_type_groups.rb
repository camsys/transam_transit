class UpdateAssetFleetTypeGroups < ActiveRecord::DataMigration
  def up
    AssetFleetType.find_by(class_name: 'RevenueVehicle').update!( groups:
                                                                      "transit_assets.fta_type_type, transit_assets.fta_type_id,revenue_vehicles.dedicated,transam_assets.manufacturer_id,transam_assets.other_manufacturer,transam_assets.manufacturer_model_id,transam_assets.other_manufacturer_model,transam_assets.manufacture_year,transam_assets.rebuilt_year,service_vehicles.fuel_type_id,service_vehicles.dual_fuel_type_id,revenue_vehicles.fta_ownership_type_id,revenue_vehicles.fta_funding_type_id,service_vehicles.vehicle_length,service_vehicles.vehicle_length_unit,service_vehicles.seating_capacity,revenue_vehicles.standing_capacity")

    AssetFleet.all.each do |fleet|
      asset_to_follow = TransamAsset.get_typed_asset(fleet.active_assets.first)

      fleet.assets_asset_fleets.where.not(transam_asset_id: fleet.active_assets.first.id).each do |assets_asset_fleet|
        typed_asset = TransamAsset.get_typed_asset(assets_asset_fleet.asset)
        is_valid = true

        (fleet.asset_fleet_type.standard_group_by_fields.map{|x| x.split('.').last} + fleet.asset_fleet_type.custom_group_by_fields).each do |field|
          if asset_to_follow.send(field) != typed_asset.send(field)
            is_valid = false
            break
          end
        end

        assets_asset_fleet.update(active: is_valid)
      end

    end
  end
end