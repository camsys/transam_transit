qc = QueryCategory.find_by(name: 'Life Cycle (Performance Restriction)')

# create period view
view_sql = <<-SQL
  CREATE OR REPLACE VIEW track_most_recent_performance_restrictions_period_view AS
    SELECT mrae.asset_event_id, mrae.base_transam_asset_id, IF(ae.period_length IS NULL, "Until Removed", "Set Length") AS period, ae.period_length, ae.period_length_unit
    FROM query_tool_most_recent_asset_events_for_type_view AS mrae
    LEFT JOIN asset_events AS ae ON ae.id = mrae.asset_event_id
    LEFT JOIN transam_assets AS tma ON mrae.base_transam_asset_id = tma.id
    LEFT JOIN transit_assets AS tta ON tta.id = tma.transam_assetible_id AND tma.transam_assetible_type = 'TransitAsset'
    LEFT JOIN fta_asset_classes AS fac ON fac.id = tta.fta_asset_class_id
    WHERE ae.id = mrae.asset_event_id AND fac.name = 'Track' AND mrae.asset_event_name = 'Performance restrictions';
SQL

ActiveRecord::Base.connection.execute view_sql

data_table = QueryAssetClass.find_or_create_by(
    table_name: 'track_most_recent_performance_restrictions_period_view',
    transam_assets_join: "LEFT JOIN track_most_recent_performance_restrictions_period_view on track_most_recent_performance_restrictions_period_view.base_transam_asset_id = transam_assets.id"
)

#create query fields
fields = [
    {
        name: 'period',
        label: 'Period',
        filter_type: 'multi_select'
    },
    {
        name: 'period_length',
        label: 'Period of Time',
        filter_type: 'numeric',
        pairs_with: 'period_length_unit'
    },
    {
        name: 'period_length_unit',
        label: 'Unit',
        filter_type: 'text',
        hidden: true
    }
]

fields.each do |f|
  qf = QueryField.find_or_create_by(
      name: f[:name],
      label: f[:label],
      query_category: qc,
      filter_type: f[:filter_type],
      hidden: f[:hidden],
      pairs_with: f[:pairs_with]
  )
  qf.query_asset_classes = [data_table]
end
