class CreateVehicleRebuildTypes < ActiveRecord::Migration
  def change
    create_table :vehicle_rebuild_types do |t|
      t.boolean :active, :null => false
      t.string :name, :null => false
      t.text :description
    end

    add_column :assets, :vehicle_rebuild_type_id, :integer,   :after => :vehicle_storage_method_type_id
  end
end
