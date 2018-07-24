class AddAssociationTransamAssetsAssetFleets < ActiveRecord::Migration[5.2]
  def change
    add_column :assets_asset_fleets, :transam_asset_id, :integer, after: :asset_id
  end
end
