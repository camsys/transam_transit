class AddActiveAssetsAssetFleets < ActiveRecord::Migration[4.2]
  def change
    add_column :assets_asset_fleets, :active, :boolean
    remove_column :asset_fleets, :homogeneous
  end
end
