class ChangeAssetIdsNullableVehicleFacilityFeatures < ActiveRecord::Migration[5.2]
  def change
    change_column :assets_facility_features, :asset_id, :integer, null: true
    change_column :assets_vehicle_features, :asset_id, :integer, null: true
  end
end
