class AddRestrictionCauseToQueryTool < ActiveRecord::DataMigration
  def up
    qf = QueryField.find_or_create_by(
        name: 'performance_restriction_type_id',
        label: 'Restriction Cause',
        query_category: QueryCategory.find_or_create_by(name: "Life Cycle (Performance Restriction)"),
        query_association_class_id: QueryAssociationClass.find_or_create_by(table_name: 'performance_restriction_types', display_field_name: 'name').try(:id),
        filter_type: 'multi_select',
        column_filter: 'mrae_types.class_name',
        column_filter_value: 'PerformanceRestrictionUpdateEvent',
        )
    qf.query_asset_classes << QueryAssetClass.find_by_table_name('most_recent_asset_events')
  end
end