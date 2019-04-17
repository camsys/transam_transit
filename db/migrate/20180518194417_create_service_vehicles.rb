class CreateServiceVehicles < ActiveRecord::Migration[5.2]
  def change
    create_table :service_vehicles do |t|
      t.references :service_vehiclible, polymorphic: true, index: {name: :service_vehiclible_idx}
      t.references :chassis
      t.string :other_chassis
      t.references :fuel_type
      t.references :dual_fuel_type
      t.string :other_fuel_type
      t.string :license_plate
      t.integer :vehicle_length
      t.string :vehicle_length_unit
      t.integer :gross_vehicle_weight
      t.string :gross_vehicle_weight_unit
      t.integer :seating_capacity
      t.integer :wheelchair_capacity
      t.references :ramp_manufacturer
      t.string :other_ramp_manufacturer
      t.boolean :ada_accessible

      t.timestamps
    end
  end
end
