class AddOdometerReadingAtMaintenanceEventToQueryTool < ActiveRecord::DataMigration
  def up
    qf = QueryField.find_or_create_by(
        name: 'current_mileage',
        label: 'Odometer Reading at Maintenance Event',
        filter_type: 'numeric',
        column_filter: 'mrae_types.class_name',
        column_filter_value: 'MaintenanceUpdateEvent',
        query_category: QueryCategory.find_by(name: 'Life Cycle (Maintenance)'),
    )
    qf.query_asset_classes << QueryAssetClass.find_by_table_name('most_recent_asset_events')
  end
end