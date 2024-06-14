class AddSerialNumberIndexToServiceVehicles < ActiveRecord::Migration[5.2]
  def change
    add_index :service_vehicles, :serial_number, name: :serial_number_idx1
  end
end
