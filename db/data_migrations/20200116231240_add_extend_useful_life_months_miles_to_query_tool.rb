class AddExtendUsefulLifeMonthsMilesToQueryTool < ActiveRecord::DataMigration
  def up
    ['months', 'miles'].each do |f|
      qf = QueryField.find_or_create_by(
          name: "extended_useful_life_#{f}",
          label: "Extend Useful Life by (#{f})",
          query_category: QueryCategory.find_by(name: 'Life Cycle (Rebuild/Rehabilitation)'),
          filter_type: 'numeric',
          column_filter: 'mrae_types.class_name',
          column_filter_value: 'RehabilitationUpdateEvent'
      )
      qf.query_asset_classes << QueryAssetClass.find_by_table_name('most_recent_asset_events')
    end
  end
end