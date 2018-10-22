class MakeTransamAssetPolymorphicFtaModeServiceType < ActiveRecord::Migration[5.2]
  def change
    add_column :assets_fta_mode_types, :transam_asset_type, :string, after: :asset_id
    add_column :assets_fta_service_types, :transam_asset_type, :string, after: :asset_id
  end
end
