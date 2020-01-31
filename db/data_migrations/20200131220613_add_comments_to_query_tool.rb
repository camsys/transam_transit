class AddCommentsToQueryTool < ActiveRecord::DataMigration
  def up
    qf = QueryField.find_or_create_by(
        name: 'comments',
        label: 'Comments',
        query_category: QueryCategory.find_or_create_by(name: 'Life Cycle (History Log)'),
        filter_type: 'text'
    )
    qf.query_asset_classes << QueryAssetClass.find_by(table_name: 'most_recent_asset_events')
  end
end