class AddFtaModeToNtdRevenueVehicleFleets < ActiveRecord::Migration[4.2]
  def change
    unless column_exists? :ntd_revenue_vehicle_fleets, :additional_fta_mode
      add_column :ntd_revenue_vehicle_fleets, :additional_fta_mode, :integer, :null => true
    end
  end
end

