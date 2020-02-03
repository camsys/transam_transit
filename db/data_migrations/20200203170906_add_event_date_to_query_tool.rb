class AddEventDateToQueryTool < ActiveRecord::DataMigration
  def up
    qf = QueryField.find_or_create_by(
        name: 'event_date',
        label: 'Event Date',
        query_category: QueryCategory.find_or_create_by(name: 'Life Cycle (History Log)'),
        filter_type: 'date'
    )
    qf.query_asset_classes << QueryAssetClass.find_by(table_name: 'most_recent_asset_events')

    QueryField.find_by(name: "disposition_date")&.destroy
  end
end