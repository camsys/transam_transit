class SetDefaultDedicatedVehicles < ActiveRecord::DataMigration
  def up
    # dedicated is a required field so for now set all vehicles as dedicated

    Vehicle.where('dedicated IS NULL').update_all(dedicated: true)
  end
end