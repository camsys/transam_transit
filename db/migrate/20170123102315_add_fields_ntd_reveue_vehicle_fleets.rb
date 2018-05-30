class AddFieldsNtdReveueVehicleFleets < ActiveRecord::Migration
  def change
    unless column_exists? :ntd_revenue_vehicle_fleets, :avg_expected_service_years
      add_column :ntd_revenue_vehicle_fleets, :avg_expected_service_years, :integer, :null => false
    end
    unless column_exists? :ntd_revenue_vehicle_fleets, :useful_life_remaining
      add_column :ntd_revenue_vehicle_fleets, :useful_life_remaining, :integer, :null => false
    end
    unless column_exists? :ntd_revenue_vehicle_fleets, :manufacture_year
      add_column :ntd_revenue_vehicle_fleets, :manufacture_year, :integer, :null => false
    end
  end
end

