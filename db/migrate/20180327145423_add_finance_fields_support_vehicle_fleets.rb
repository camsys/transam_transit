class AddFinanceFieldsSupportVehicleFleets < ActiveRecord::Migration[4.2]
  def change
    add_column :asset_fleets, :estimated_cost, :integer, after: :ntd_id
    add_column :asset_fleets, :year_estimated_cost, :integer, after: :estimated_cost
  end
end
