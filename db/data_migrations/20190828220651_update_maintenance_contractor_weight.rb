class UpdateMaintenanceContractorWeight < ActiveRecord::DataMigration
  def up
    Role.find_by(name: :maintenance_contractor)&.update(weight: 2)
  end

  def down
    Role.find_by(name: :maintenance_contractor)&.update(weight: nil)
  end
end