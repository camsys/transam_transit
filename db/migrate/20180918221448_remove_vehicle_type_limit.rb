class RemoveVehicleTypeLimit < ActiveRecord::Migration[5.2]
  def up
    change_column :ntd_revenue_vehicle_fleets, :vehicle_type, :string, :limit => nil
    change_column :ntd_service_vehicle_fleets, :vehicle_type, :string, :limit => nil
  end
  
  def down
    change_column :ntd_revenue_vehicle_fleets, :vehicle_type, :string, :limit => 32
    change_column :ntd_service_vehicle_fleets, :vehicle_type, :string, :limit => 32
  end
end
