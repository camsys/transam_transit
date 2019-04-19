class TempAddEstimatedCostFleets < ActiveRecord::Migration[5.2]
  def change
    add_column :asset_fleets, :estimated_cost, :integer
    add_column :asset_fleets, :year_estimated_cost, :integer
  end
end
