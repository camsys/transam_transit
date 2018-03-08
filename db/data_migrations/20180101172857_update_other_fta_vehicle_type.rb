class UpdateOtherFtaVehicleType < ActiveRecord::DataMigration
  def up
    FtaVehicleType.find_by(name: 'Unknown').update!(name: 'Other', code: 'OR') if FtaVehicleType.find_by(name: 'Unknown')
  end
end