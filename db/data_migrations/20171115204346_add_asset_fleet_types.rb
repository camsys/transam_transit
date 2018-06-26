class AddAssetFleetTypes < ActiveRecord::DataMigration
  def up
    AssetFleetType.create!({
           groups: 'asset_type_id,asset_subtype_id,fta_vehicle_type_id,dedicated,manufacturer_id,other_manufacturer,manufacture_year,fuel_type_id,dual_fuel_type_id,fta_ownership_type_id,fta_funding_type_id',
           custom_groups: 'primary_fta_mode_type_id,secondary_fta_mode_type_id,direct_capital_responsibility,primary_fta_service_type_id,secondary_fta_service_type_id',
           class_name: 'Vehicle',
           active: true
     }) if AssetFleetType.find_by(class_name: 'Vehicle').nil?
    AssetFleetType.create!({
           groups: 'asset_type_id,asset_subtype_id,fta_support_vehicle_type_id,manufacture_year,scheduled_replacement_cost,pcnt_capital_responsibility,scheduled_replacement_year',
           custom_groups: 'primary_fta_mode_type_id,secondary_fta_mode_types',
           class_name: 'SupportVehicle',
           active: true
     }) if AssetFleetType.find_by(class_name: 'SupportVehicle').nil?
  end
end