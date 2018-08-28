class AddAssociationTransamAssetsAssetFleets < ActiveRecord::Migration[5.2]
  def change
    add_reference :assets_asset_fleets, :transam_asset, after: :asset_id
  end
end
