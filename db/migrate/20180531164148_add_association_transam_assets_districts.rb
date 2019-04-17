class AddAssociationTransamAssetsDistricts < ActiveRecord::Migration[5.2]
  def change
    add_column :assets_districts, :id, :primary_key, first: true
    add_reference :assets_districts, :transam_asset, after: :asset_id
  end
end
