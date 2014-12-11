class RemoveDefaultFromAssetFtaBusModeType < ActiveRecord::Migration
  def up
    change_column :assets, :fta_bus_mode_type_id, :integer, :after => :fta_funding_type_id
  end
end
