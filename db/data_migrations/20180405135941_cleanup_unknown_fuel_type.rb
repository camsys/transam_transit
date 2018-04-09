class CleanupUnknownFuelType < ActiveRecord::DataMigration
  def up
    Asset.where(fuel_type_id: FuelType.find_by(name: 'Unknown').id).update_all(fuel_type_id: FuelType.find_by(name: 'Other').id, other_fuel_type: 'Unknown')
    FuelType.find_by(name: 'Unknown').destroy!
  end
end