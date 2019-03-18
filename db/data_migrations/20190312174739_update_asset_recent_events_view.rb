class UpdateAssetRecentEventsView < ActiveRecord::DataMigration
  def up
    view_sql = <<-SQL
      CREATE OR REPLACE VIEW all_assets_recent_asset_events_for_type_view AS
            SELECT
              aet.id AS asset_event_type_id, aet.name AS asset_event_name, Max(ae.created_at) AS asset_event_created_time, ae.base_transam_asset_id, Max(ae.id) AS asset_event_id
            FROM asset_events AS ae
            LEFT JOIN asset_event_types AS aet ON aet.id = ae.asset_event_type_id
            LEFT JOIN transam_assets AS ta  ON ta.id = ae.base_transam_asset_id
            GROUP BY aet.id, ae.base_transam_asset_id;
    SQL

    ActiveRecord::Base.connection.execute view_sql

    # update query field config
    qac = QueryAssetClass.find_by_table_name 'most_recent_asset_events'
    if qac
      qac.update transam_assets_join: "left join all_assets_recent_asset_events_for_type_view mraev on mraev.base_transam_asset_id = transam_assets.id left join asset_events as most_recent_asset_events on most_recent_asset_events.id = mraev.asset_event_id left join asset_event_types as mrae_types on most_recent_asset_events.asset_event_type_id = mrae_types.id"
    end
  end
end