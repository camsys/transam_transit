class AddVehicleRebuildTypeReference < ActiveRecord::Migration[5.2]
  def change
    add_column :asset_events, :vehicle_rebuild_type_id, :integer, index: true
    add_column :asset_events, :other_vehicle_rebuild_type, :string
  end
end
