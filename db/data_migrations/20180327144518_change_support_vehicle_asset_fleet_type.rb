class ChangeSupportVehicleAssetFleetType < ActiveRecord::DataMigration
  def up
    AssetFleetType.find_by(class_name: 'SupportVehicle').update!(groups: "asset_type_id,asset_subtype_id,fta_support_vehicle_type_id,manufacture_year,pcnt_capital_responsibility")
  end
end