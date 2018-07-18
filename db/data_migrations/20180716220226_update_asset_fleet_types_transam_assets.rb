class UpdateAssetFleetTypesTransamAssets < ActiveRecord::DataMigration
  def up


    AssetFleetType.create!(
        class_name: "RevenueVehicle",
        groups:
        "transit_assets.fta_type_type, transit_assets.fta_type_id,revenue_vehicles.dedicated,transam_assets.manufacturer_id,transam_assets.other_manufacturer,transam_assets.manufacturer_model,transam_assets.manufacture_year,service_vehicles.fuel_type_id,service_vehicles.dual_fuel_type_id,revenue_vehicles.fta_ownership_type_id,revenue_vehicles.fta_funding_type_id",
        custom_groups:
        "primary_fta_mode_type_id,secondary_fta_mode_type_id,direct_capital_responsibility,primary_fta_service_type_id,secondary_fta_service_type_id",
        label_groups: "primary_fta_mode_service,manufacturer,manufacture_year",
        active: true
    )
    AssetFleetType.create!(
        class_name: "ServiceVehicle",
        groups:
        "transit_assets.fta_type_type, transit_assets.fta_type_id,transam_assets.manufacture_year,transit_assets.pcnt_capital_responsibility",
        custom_groups: "primary_fta_mode_type_id,secondary_fta_mode_types",
        label_groups: "primary_fta_mode_type,manufacture_year",
        active: true
    )

  end
end