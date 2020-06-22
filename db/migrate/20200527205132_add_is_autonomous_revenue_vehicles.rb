class AddIsAutonomousRevenueVehicles < ActiveRecord::Migration[5.2]
  def change
    add_column :revenue_vehicles, :is_autonomous, :boolean, after: :dedicated
    add_column :ntd_revenue_vehicle_fleets, :is_autonomous, :string, after: :dedicated
    add_column :ntd_revenue_vehicle_fleets, :fta_asset_class, :string, after: :vehicle_object_key
  end
end
