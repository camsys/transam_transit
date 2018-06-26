class CreateLabelAssetFleetTypes < ActiveRecord::DataMigration
  def up
    AssetFleetType.where.not(class_name: 'SupportVehicle').update_all(label_groups: 'primary_fta_mode_service,manufacturer,manufacture_year')
    AssetFleetType.where(class_name: 'SupportVehicle').update_all(label_groups: 'primary_fta_mode_type,manufacture_year')
  end
end