class CreateFtaSupportVehicleTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :fta_support_vehicle_types do |t|
      t.string  "name",        :null => false
      t.string  "description", :null => false
      t.boolean "active",      :null => false
    end

    add_reference :assets, :fta_support_vehicle_type, after: :fta_vehicle_type_id
  end
end
