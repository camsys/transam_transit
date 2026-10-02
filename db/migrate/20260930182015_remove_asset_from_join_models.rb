class RemoveAssetFromJoinModels < ActiveRecord::Migration[5.2]
  def change
    remove_column :assets_districts, :asset_id, :integer
  end
end
