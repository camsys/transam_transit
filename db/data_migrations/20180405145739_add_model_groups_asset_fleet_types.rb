class AddModelGroupsAssetFleetTypes < ActiveRecord::DataMigration
  def up
    AssetFleetType.where.not(class_name: 'SupportVehicle').update_all(groups: 'asset_type_id,asset_subtype_id,fta_vehicle_type_id,dedicated,manufacturer_id,other_manufacturer,manufacturer_model,manufacture_year,fuel_type_id,dual_fuel_type_id,fta_ownership_type_id,fta_funding_type_id')
  end
end