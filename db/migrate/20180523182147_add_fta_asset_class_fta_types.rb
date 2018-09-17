class AddFtaAssetClassFtaTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :fta_vehicle_types, :fta_asset_class_id, :integer, after: :id
    add_column :fta_facility_types, :fta_asset_class_id, :integer, after: :id
    add_column :fta_support_vehicle_types, :fta_asset_class_id, :integer, after: :id
  end
end
