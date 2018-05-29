class AddTransitAssetAssetsHabtmTables < ActiveRecord::Migration[5.2]
  def change
    add_column :assets_fta_mode_types, :transit_asset_id, :integer, after: :asset_id
    add_column :assets_fta_service_types, :transit_asset_id, :integer, after: :asset_id
    add_column :assets_vehicle_features, :transit_asset_id, :integer, after: :asset_id
    add_column :assets_facility_features, :transit_asset_id, :integer, after: :asset_id
  end
end
