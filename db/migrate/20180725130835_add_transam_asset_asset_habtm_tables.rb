class AddTransamAssetAssetHabtmTables < ActiveRecord::Migration[5.2]
  def change
    add_reference :assets_fta_mode_types, :transam_asset, after: :asset_id
    add_reference :assets_fta_service_types, :transam_asset, after: :asset_id
    add_reference :assets_vehicle_features, :transam_asset, after: :asset_id
    add_reference :assets_facility_features, :transam_asset, after: :asset_id
  end
end
