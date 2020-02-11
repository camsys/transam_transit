class AddMileageAtDispositionToQueryTool < ActiveRecord::DataMigration
  def up
    qf = QueryField.find_or_create_by(
        name: 'current_mileage',
        label: 'Mileage at Disposition',
        filter_type: 'numeric',
        column_filter: 'mrae_types.class_name',
        column_filter_value: 'DispositionUpdateEvent',
        query_category: QueryCategory.find_by(name: 'Life Cycle (Disposition & Transfer)'),
        )
    qf.query_asset_classes << QueryAssetClass.find_by_table_name('most_recent_asset_events')
  end
end