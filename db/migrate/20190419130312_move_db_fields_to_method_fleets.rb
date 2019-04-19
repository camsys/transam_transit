class MoveDbFieldsToMethodFleets < ActiveRecord::Migration[5.2]
  def change
    remove_column :asset_fleets, :estimated_cost
    remove_column :asset_fleets, :year_estimated_cost
  end
end
