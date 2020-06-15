class ChangeVehicleRebuildTypes < ActiveRecord::DataMigration
  def up
    rebuild_type = VehicleRebuildType.find_by(name: 'Mid-Life Powertrain')
    new_rebuild_type = VehicleRebuildType.find_by(name: 'Mid-Life Overhaul')

    RehabilitationUpdateEvent.where(vehicle_rebuid_type_id: rebuild_type.id).update_all(comments: 'Originally reported as a Mid-Life Powertrain; selected value updated to match updated NTD reporting standards.', vehicle_rebuild_type_id: new_rebuild_type.id)

    rebuild_type.destroy!
  end
end