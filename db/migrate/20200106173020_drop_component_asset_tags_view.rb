class DropComponentAssetTagsView < ActiveRecord::Migration[5.2]
  def change
    self.connection.execute "DROP VIEW if exists component_asset_tags_view;"
  end
end
