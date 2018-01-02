class AddFtaSupportVehicleTypes < ActiveRecord::DataMigration
  def up
    fta_support_vehicle_types = [
        {name: 'Automobiles', description: 'Automobiles', active: true},
        {name: 'Trucks and other Rubber Tire Vehicles', description: 'Trucks and other Rubber Tire Vehicles', active: true},
        {name: 'Steel Wheel Vehicles', description: 'Steel Wheel Vehicles', active: true}
    ]

    fta_support_vehicle_types.each do |type|
      FtaSupportVehicleType.create!(type)
    end
  end

  def down
    FtaSupportVehicleType.delete_all
  end
end