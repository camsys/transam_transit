class AddOtherOwnershipAndFuelTypesToRevenueFleets < ActiveRecord::Migration[5.2]
  def change
    add_column :ntd_revenue_vehicle_fleets, :other_ownership_type, :string
    add_column :ntd_revenue_vehicle_fleets, :other_fuel_type, :string
  end
end
