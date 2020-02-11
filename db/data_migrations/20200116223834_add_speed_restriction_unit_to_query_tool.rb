class AddSpeedRestrictionUnitToQueryTool < ActiveRecord::DataMigration
  def up
    qf = QueryField.find_or_create_by(
        name: 'speed_restriction_unit',
        label: 'Unit',
        query_category: QueryCategory.find_by(name: 'Life Cycle (Performance Restriction)'),
        filter_type: 'text',
        hidden: true
    )
    qf.query_asset_classes << QueryAssetClass.find_by(table_name: 'most_recent_asset_events')

    QueryField.find_by(name: 'speed_restriction').update(pairs_with: 'speed_restriction_unit')
  end
end