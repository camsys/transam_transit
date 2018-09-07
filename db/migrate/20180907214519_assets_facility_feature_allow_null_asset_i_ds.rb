class AssetsFacilityFeatureAllowNullAssetIDs < ActiveRecord::Migration[5.2]
  def change
    change_column_null :assets_facility_features, :asset_id, true
    add_index :assets_facility_features, [:transam_asset_id, :facility_feature_id], name: :transam_assets_facility_features_idx1
  end
end
