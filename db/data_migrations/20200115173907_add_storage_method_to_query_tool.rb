class AddStorageMethodToQueryTool < ActiveRecord::DataMigration
  def up
    qf = QueryField.find_or_create_by(
        name: 'vehicle_storage_method_type_id',
        label: 'Storage Method',
        query_category: QueryCategory.find_or_create_by(name: "Life Cycle (Location / Storage)"),
        query_association_class_id: QueryAssociationClass.find_or_create_by(table_name: 'vehicle_storage_method_types', display_field_name: 'name').try(:id),
        filter_type: 'multi_select',
        column_filter: 'mrae_types.class_name',
        column_filter_value: 'StorageMethodUpdateEvent',
    )
    qf.query_asset_classes << QueryAssetClass.find_by_table_name('most_recent_asset_events')
  end
end