class AddFinanceFieldsSupportVehicleFleets < ActiveRecord::Migration
  def change
    add_column :asset_fleets, :estimated_cost, :integer, after: :ntd_id
    add_column :asset_fleets, :year_estimated_cost, :integer, after: :estimated_cost
  end
end
