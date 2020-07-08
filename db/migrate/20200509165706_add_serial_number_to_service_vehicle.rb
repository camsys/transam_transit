class AddSerialNumberToServiceVehicle < ActiveRecord::Migration[5.2]
  def change
    add_column :service_vehicles, :serial_number, :string, null: false 
  end
end
