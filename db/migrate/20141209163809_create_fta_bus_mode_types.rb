class CreateFtaBusModeTypes < ActiveRecord::Migration
  def up
    create_table :fta_bus_mode_types do |t|
      t.string :name,      :limit => 64,   :null => false
    	t.string :code,      :limit => 3,    :null => false
    	t.text :description, :limit => 254,  :null => false
      t.boolean :active,   :null => false
    end
  end
  def down
  	drop_table :fta_bus_mode_types
  end
end
