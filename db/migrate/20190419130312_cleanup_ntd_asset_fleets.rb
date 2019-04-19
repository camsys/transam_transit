class CleanupNtdAssetFleets < ActiveRecord::Migration[5.2]
  def change
    remove_column :asset_fleets, :estimated_cost
    remove_column :asset_fleets, :year_estimated_cost
    add_column :ntd_service_vehicle_fleets, :status, :string, after: :notes
  end
end
