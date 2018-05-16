class AddPrimaryKeyAssetsAssetFleets < ActiveRecord::Migration
  def change
    add_column :assets_asset_fleets, :id, :primary_key, first: true
  end
end
