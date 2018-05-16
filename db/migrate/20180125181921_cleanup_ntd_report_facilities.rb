class CleanupNtdReportFacilities < ActiveRecord::Migration
  def change
    remove_column :ntd_admin_and_maintenance_facilities, :estimated_cost
    remove_column :ntd_admin_and_maintenance_facilities, :estimated_cost_year

    add_column :ntd_admin_and_maintenance_facilities, :facility_id, :string, after: :ntd_form_id
    add_column :ntd_admin_and_maintenance_facilities, :secondary_mode, :string, after: :primary_mode
    add_column :ntd_admin_and_maintenance_facilities, :private_mode, :string, after: :secondary_mode

  end
end
