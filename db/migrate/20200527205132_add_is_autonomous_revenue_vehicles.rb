class AddIsAutonomousRevenueVehicles < ActiveRecord::Migration[5.2]
  def change
    add_column :revenue_vehicles, :is_autonomous, :boolean, after: :dedicated
    add_column :ntd_revenue_vehicl_fleets, :is_autonomous, :string, after: :dedicated
  end
end
