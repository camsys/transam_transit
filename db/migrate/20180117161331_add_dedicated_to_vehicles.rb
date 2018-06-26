class AddDedicatedToVehicles < ActiveRecord::Migration[4.2]
  def change
    add_column :assets, :dedicated, :boolean, after: :fta_emergency_contingency_fleet
  end
end
