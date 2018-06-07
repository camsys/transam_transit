class AddAssociationTransamAssetsDistricts < ActiveRecord::Migration[5.2]
  def change
    add_column :assets_districts, :id, :primary_key, first: true
    add_column :assets_districts, :transam_asset_id, :integer, after: :asset_id
  end
end
