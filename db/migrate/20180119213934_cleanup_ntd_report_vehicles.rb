class CleanupNtdReportVehicles < ActiveRecord::Migration
  def change

    remove_column :ntd_revenue_vehicle_fleets, :funding_source
    remove_column :ntd_revenue_vehicle_fleets, :renewal_year
    remove_column :ntd_revenue_vehicle_fleets, :renewal_type
    remove_column :ntd_revenue_vehicle_fleets, :renewal_cost
    remove_column :ntd_revenue_vehicle_fleets, :replacement_cost
    remove_column :ntd_revenue_vehicle_fleets, :replacement_cost_year
    remove_column :ntd_revenue_vehicle_fleets, :renewal_cost_year
    remove_column :ntd_revenue_vehicle_fleets, :replacement_cost_parts
    remove_column :ntd_revenue_vehicle_fleets, :replacement_cost_warranty
    remove_column :ntd_revenue_vehicle_fleets, :avg_expected_service_years

    add_column :ntd_revenue_vehicle_fleets, :agency_fleet_id, :string, after: :rvi_id
    add_column :ntd_revenue_vehicle_fleets, :dedicated, :string, after: :agency_fleet_id
    add_column :ntd_revenue_vehicle_fleets, :direct_capital_responsibility, :string, after: :dedicated
    add_column :ntd_revenue_vehicle_fleets, :rebuilt_year, :string, after: :manufacture_code
    add_column :ntd_revenue_vehicle_fleets, :other_manufacturer, :string, after: :model_number
    add_column :ntd_revenue_vehicle_fleets, :dual_fuel_type, :string, after: :fuel_type
    add_column :ntd_revenue_vehicle_fleets, :ownership_type, :string, after: :avg_lifetime_active_miles
    add_column :ntd_revenue_vehicle_fleets, :funding_type, :string, after: :ownership_type
    add_column :ntd_revenue_vehicle_fleets, :useful_life_benchmark, :string, after: :useful_life_remaining
    add_column :ntd_revenue_vehicle_fleets, :status, :string, after: :notes
    add_column :ntd_revenue_vehicle_fleets, :additional_fta_service_type, :string, after: :additional_fta_mode
    add_column :ntd_revenue_vehicle_fleets, :fta_mode, :string, after: :rvi_id
    add_column :ntd_revenue_vehicle_fleets, :fta_service_type, :string, after: :fta_mode

  end
end
