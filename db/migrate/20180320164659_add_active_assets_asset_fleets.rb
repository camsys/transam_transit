class AddActiveAssetsAssetFleets < ActiveRecord::Migration
  def change
    add_column :assets_asset_fleets, :active, :boolean
    remove_column :asset_fleets, :homogeneous
  end
end
