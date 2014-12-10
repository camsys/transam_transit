class CreateFtaBusModeTypes < ActiveRecord::Migration
  def up
    create_table :fta_bus_mode_types do |t|
    	t.boolean :active, :null => false
    	t.string :code, :null => false
    	t.string :name, :null => false
    	t.text :description
    end
  end
  def down
  	drop_table :fta_bus_mode_types
  end
end
