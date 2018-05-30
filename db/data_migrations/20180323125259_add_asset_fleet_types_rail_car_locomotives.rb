class AddAssetFleetTypesRailCarLocomotives < ActiveRecord::DataMigration
  def up
    if Rails.application.config.transam_transit_rail == true
      AssetFleetType.create!({
                                 groups: 'asset_type_id,asset_subtype_id,fta_vehicle_type_id,dedicated,manufacturer_id,other_manufacturer,manufacture_year,fuel_type_id,dual_fuel_type_id,fta_ownership_type_id,fta_funding_type_id',
                                 custom_groups: 'primary_fta_mode_type_id,secondary_fta_mode_type_id,direct_capital_responsibility,primary_fta_service_type_id,secondary_fta_service_type_id',
                                 class_name: 'RailCar',
                                 active: true
                             }) if AssetFleetType.find_by(class_name: 'RailCar').nil?
      AssetFleetType.create!({
                                 groups: 'asset_type_id,asset_subtype_id,fta_vehicle_type_id,dedicated,manufacturer_id,other_manufacturer,manufacture_year,fuel_type_id,dual_fuel_type_id,fta_ownership_type_id,fta_funding_type_id',
                                 custom_groups: 'primary_fta_mode_type_id,secondary_fta_mode_type_id,direct_capital_responsibility,primary_fta_service_type_id,secondary_fta_service_type_id',
                                 class_name: 'Locomotive',
                                 active: true
                             }) if AssetFleetType.find_by(class_name: 'Locomotive').nil?
    end
  end
end