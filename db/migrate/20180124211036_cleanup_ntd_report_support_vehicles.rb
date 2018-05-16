class CleanupNtdReportSupportVehicles < ActiveRecord::Migration
  def change

    remove_column :ntd_service_vehicle_fleets, :avg_expected_years

    add_column :ntd_service_vehicle_fleets, :sv_id, :string, after: :ntd_form_id
    add_column :ntd_service_vehicle_fleets, :agency_fleet_id, :string, after: :sv_id
    add_column :ntd_service_vehicle_fleets, :fleet_name, :string, after: :sv_id
    add_column :ntd_service_vehicle_fleets, :primary_fta_mode_type, :string, after: :vehicle_type
    add_column :ntd_service_vehicle_fleets, :useful_life_benchmark, :string, after: :estimated_cost_year
    add_column :ntd_service_vehicle_fleets, :useful_life_remaining, :string, after: :useful_life_benchmark
    add_column :ntd_service_vehicle_fleets, :secondary_fta_mode_types, :string, after: :primary_fta_mode_type
  end
end
