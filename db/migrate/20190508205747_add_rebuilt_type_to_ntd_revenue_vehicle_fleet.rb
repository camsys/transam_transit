class AddRebuiltTypeToNtdRevenueVehicleFleet < ActiveRecord::Migration[5.2]
  def change
    add_column :ntd_revenue_vehicle_fleets, :rebuilt_type, :string
  end
end
