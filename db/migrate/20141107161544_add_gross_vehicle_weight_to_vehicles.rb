class AddGrossVehicleWeightToVehicles < ActiveRecord::Migration
def change
  change_table :assets do |t|
    t.integer :gross_vehicle_weight, :after => :vehicle_length
  end
end
end
