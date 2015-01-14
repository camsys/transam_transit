class AddNumParkingSpaces < ActiveRecord::Migration
  def change
    add_column :assets, :num_parking_spaces_public, :integer, :after => :num_escalators
    add_column :assets, :num_parking_spaces_private, :integer, :after => :num_parking_spaces_public
  end
end
