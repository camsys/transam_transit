class ChangeRviIdLimit < ActiveRecord::Migration[5.2]
  def up
    change_column :ntd_revenue_vehicle_fleets, :rvi_id, :string, :limit => 32
  end
  
  def down
    change_column :ntd_revenue_vehicle_fleets, :rvi_id, :string, :limit => 4
  end
end
