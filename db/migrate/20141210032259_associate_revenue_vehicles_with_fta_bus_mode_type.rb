class AssociateRevenueVehiclesWithFtaBusModeType < ActiveRecord::Migration
  def up
  	add_column    :assets, :fta_bus_mode_type_id, :integer, :default => 0
  end
  def down
  	remove_column :assets, :fta_bus_mode_type_id
  end
end
