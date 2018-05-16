class AddReportedConditionDateToNtdAdminAndMaintenanceFacilities < ActiveRecord::Migration
  def change
    add_column :ntd_admin_and_maintenance_facilities, :reported_condition_date, :date, :null => true
    add_column :ntd_passenger_and_parking_facilities, :reported_condition_date, :date, :null => true
  end
end
