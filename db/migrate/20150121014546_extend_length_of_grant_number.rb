class ExtendLengthOfGrantNumber < ActiveRecord::Migration
  def change
    change_column :grants, :grant_number, :limit => 64, :null => false
  end
end
