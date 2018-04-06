class CleanupFtaSupportVehicleTypes < ActiveRecord::DataMigration
  def up
    FtaSupportVehicleType.create!(name: 'Unknown', description: 'Unknown', active: false) if FtaSupportVehicleType.find_by(name: 'Unknown').nil?

    # set fta support vehicle by mapping asset subtype
    subtypes = AssetSubtype.where(asset_type: AssetType.find_by(class_name: 'SupportVehicle'))

    # map to Automobiles
    SupportVehicle.where(asset_subtype_id: subtypes.where.not(name: ['Tow Truck', 'Other Support Vehicle']).pluck(:id)).update_all(fta_support_vehicle_type_id: FtaSupportVehicleType.find_by(name: 'Automobiles').id)

    # map to Trucks and other Rubber Tire Vehicles
    SupportVehicle.where(asset_subtype_id: subtypes.where(name: ['Tow Truck']).pluck(:id)).update_all(fta_support_vehicle_type_id: FtaSupportVehicleType.find_by(name: 'Trucks and other Rubber Tire Vehicles').id)

    # map Other
    SupportVehicle.where(asset_subtype_id: subtypes.where(name: ['Other Support Vehicle']).pluck(:id)).update_all(fta_support_vehicle_type_id: FtaSupportVehicleType.find_by(name: 'Unknown').id)
  end
end