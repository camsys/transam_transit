class RenameNtdAdminAndMaintenanceFacilityToNtdFacility < ActiveRecord::Migration[5.2]
  def change
    rename_table :ntd_admin_and_maintenance_facilities, :ntd_facilities

    drop_table :ntd_passenger_and_parking_facilities
  end
end
