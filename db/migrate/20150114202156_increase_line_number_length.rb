class IncreaseLineNumberLength < ActiveRecord::Migration
  def change
    change_column :assets, :line_number, :string, :limit => 128, :null => true, :after => :lot_size
  end
end
