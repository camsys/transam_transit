class AddIndexesForAssetTables < ActiveRecord::Migration[5.2]
  def change
    add_index :transam_assets, :disposition_date, name: :disposition_date_idx1
    add_index :asset_events, :transam_asset_type, name: :transam_asset_type_idx1
    add_index :asset_events, :condition_type_id, name: :condition_type_id_idx1
    add_index :asset_events, :service_status_type_id, name: :service_status_type_id_idx1
  end
end
