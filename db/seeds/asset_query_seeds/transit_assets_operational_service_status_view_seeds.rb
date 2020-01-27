# create period view
view_sql = <<-SQL
      CREATE OR REPLACE VIEW transit_assets_operational_service_status_view AS
        SELECT transam_assets.id AS transam_asset_id, (case when transam_assets.disposition_date IS NULL 
        AND service_vehicles.fta_emergency_contingency_fleet = FALSE AND (asset_events.service_status_type_id != 2 
        OR asset_events.out_of_service_status_type_id IN (2, 3) OR service_vehiclible_type IS NULL) then 'Active' else 'Inactive' end)  AS operational_service_status
        FROM service_vehicles
        INNER JOIN transit_assets ON transit_assets.transit_assetible_id = service_vehicles.id AND transit_assets.transit_assetible_type = 'ServiceVehicle' 
        INNER JOIN transam_assets ON transam_assets.transam_assetible_id = transit_assets.id AND transam_assets.transam_assetible_type = 'TransitAsset' 
        INNER JOIN asset_events ON asset_events.transam_asset_id = transam_assets.id AND asset_events.transam_asset_type = 'TransamAsset' 
        AND asset_events.asset_event_type_id = 6
        UNION
        SELECT transam_assets.id AS transam_asset_id, (case when transam_assets.disposition_date IS NULL AND (asset_events.service_status_type_id != 2 
        OR asset_events.out_of_service_status_type_id IN (2, 3)) then 'Active' else 'Inactive' end) AS operational_service_status
        FROM transam_assets
        INNER JOIN asset_events ON asset_events.transam_asset_id = transam_assets.id AND asset_events.transam_asset_type = 'TransamAsset' 
        AND asset_events.asset_event_type_id = 6
SQL

ActiveRecord::Base.connection.execute view_sql

data_table = QueryAssetClass.find_or_create_by(
    table_name: 'transit_assets_operational_service_status_view',
    transam_assets_join: "LEFT JOIN transit_assets_operational_service_status_view on transit_assets_operational_service_status_view.transam_asset_id = transam_assets.id"
)

# query field
qf = QueryField.find_or_create_by(
    name: 'operational_service_status',
    label: 'Operational Service Status',
    filter_type: 'multi_select',
    query_category: QueryCategory.find_by(name: 'Life Cycle (Service Status)')
)
qf.query_asset_classes = [data_table]