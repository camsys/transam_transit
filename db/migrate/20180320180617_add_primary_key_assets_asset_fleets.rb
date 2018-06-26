class AddPrimaryKeyAssetsAssetFleets < ActiveRecord::Migration[4.2]
  def change
    add_column :assets_asset_fleets, :id, :primary_key, first: true
  end
end
