class AddDedicatedToVehicles < ActiveRecord::Migration
  def change
    add_column :assets, :dedicated, :boolean, after: :fta_emergency_contingency_fleet
  end
end
