class UpdateFtaVehicleTypeDefaultUlb < ActiveRecord::DataMigration
  def up
    fta_vehicle_type = FtaVehicleType.find_by(name: 'Other')
    fta_vehicle_type.default_useful_life_benchmark = 0
    fta_vehicle_type.save
  end
end