class RemoveComponentIdFromQueryTool < ActiveRecord::DataMigration
  def up
    QueryField.find_by(name: 'component_id').destroy
    QueryAssetClass.find_by(table_name: 'component_asset_tags_view').destroy
  end
end