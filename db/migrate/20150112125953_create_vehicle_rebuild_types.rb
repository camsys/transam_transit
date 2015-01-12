class CreateVehicleRebuildTypes < ActiveRecord::Migration
  def change
    create_table :vehicle_rebuild_types do |t|
      t.string :name,      :limit => 64,   :null => false
      t.text :description, :limit => 254,  :null => false
      t.boolean :active,   :null => false
    end

    add_column :assets, :vehicle_rebuild_type_id, :integer,   :after => :vehicle_storage_method_type_id
  end
end
