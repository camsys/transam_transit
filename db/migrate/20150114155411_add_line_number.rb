class AddLineNumber < ActiveRecord::Migration
  def change
    add_column :assets, :line_number, :string, :limit => 64, :null => true, :after => :lot_size
  end
end
