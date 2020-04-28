class RemoveComponentIdFromQueryTool < ActiveRecord::DataMigration
  def up
    qf = QueryField.find_by(name: 'component_id')
    qac = QueryAssetClass.find_by(table_name: 'component_asset_tags_view')

    # remove saved query fields that use the old field
    SavedQueryField.where(query_field: qf).destroy_all

    # remove saved filters using the old field
    QueryFilter.where(query_field: qf).destroy_all

    qf&.destroy
    qac&.destroy
  end
end