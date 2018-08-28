DROP VIEW if exists recent_asset_events_for_type_view;

-- Finds the most recent of each type of asset event for each transam_asset. This makes 1 huge, but hopefully safe, assumption that the largest asset event id for an asset event will be the most recent.
CREATE OR REPLACE SQL SECURITY INVOKER VIEW recent_asset_events_for_type_view AS
SELECT
aet.id AS asset_event_type_id, aet.name AS asset_event_name, Max(ae.created_at) AS asset_event_created_time, ae.transam_asset_id, Max(ae.id) AS asset_event_id
FROM asset_events AS ae
LEFT JOIN asset_event_types AS aet ON aet.id = ae.asset_event_type_id
LEFT JOIN transam_assets AS ta  ON ta.id = ae.transam_asset_id
WHERE aet.id IN ( 1, 2, 6, 8, 10, 19)
GROUP BY aet.id, ae.transam_asset_id;

DROP VIEW if exists most_recent_asset_event_view;

CREATE OR REPLACE SQL SECURITY INVOKER VIEW most_recent_asset_event_view AS
SELECT
ae.transam_asset_id, Max(ae.created_at) AS asset_event_created_time,  Max(ae.id) AS asset_event_id
FROM asset_events AS ae
LEFT JOIN asset_event_types AS aet ON aet.id = ae.asset_event_type_id
LEFT JOIN transam_assets AS ta  ON ta.id = ae.transam_asset_id
GROUP BY ae.transam_asset_id;


DROP VIEW if exists revenue_vehicle_asset_table_views;

CREATE OR REPLACE SQL SECURITY INVOKER VIEW revenue_vehicle_asset_table_views AS
SELECT
	rv.id,
	rv.id AS 'revenue_vehicle_id',
    transamAs.organization_id AS 'organization_id',
    transamAs.asset_subtype_id AS 'asset_subtype_id',
    transamAs.transam_assetible_id AS 'asset_type_id',
    transamAs.asset_tag AS 'asset_tag',
    transamAs.object_key AS 'object_key',
    transitAs.fta_asset_class_id,
    mrAev.asset_event_id AS 'most_recent_asset_event',
    rae_condition.asset_event_id AS 'condition_event_id',
    rae_service_status.asset_event_id AS 'service_status_event_id',
    rae_rebuild.asset_event_id AS 'rebuild_event_id',
    rae_mileage.asset_event_id AS 'mileage_event_id',
    rae_early_replacement_status.asset_event_id AS 'early_replacement_status_event_id',
    ag.id AS 'asset_group_id',
    fleets.id AS 'asset_fleet_id',
    fleets.ntd_id AS 'ntd_id'
FROM revenue_vehicles AS rv
LEFT JOIN service_vehicles AS sv ON sv.service_vehiclible_id = rv.id
	AND sv.service_vehiclible_type = 'RevenueVehicle'
LEFT JOIN transit_assets AS transitAs ON transitAs.transit_assetible_id = sv.id
	AND transitAs.transit_assetible_type = 'ServiceVehicle'
LEFT JOIN transam_assets AS transamAs ON transamAs.transam_assetible_id = transitAs.id
	AND transamAs.transam_assetible_type = 'TransitAsset'
LEFT JOIN most_recent_asset_event_view AS mrAev ON mrAev.transam_asset_id = transamAs.id
LEFT JOIN recent_asset_events_for_type_view AS rae_condition ON rae_condition.transam_asset_id = transamAs.id
	AND rae_condition.asset_event_type_id = 1
LEFT JOIN recent_asset_events_for_type_view AS rae_maintenance ON rae_maintenance.transam_asset_id = transamAs.id
	AND rae_maintenance.asset_event_type_id = 2
LEFT JOIN recent_asset_events_for_type_view AS rae_service_status ON rae_service_status.transam_asset_id = transamAs.id
	AND rae_service_status.asset_event_type_id = 6
LEFT JOIN recent_asset_events_for_type_view AS rae_rebuild ON rae_rebuild.transam_asset_id = transamAs.id
	AND rae_rebuild.asset_event_type_id = 8
LEFT JOIN recent_asset_events_for_type_view AS rae_mileage ON rae_mileage.transam_asset_id = transamAs.id
	AND rae_mileage.asset_event_type_id = 10
LEFT JOIN recent_asset_events_for_type_view AS rae_early_replacement_status ON rae_early_replacement_status.transam_asset_id = transamAs.id
	AND rae_early_replacement_status.asset_event_type_id = 19
LEFT JOIN asset_groups_assets AS ada ON ada.transam_asset_id = transamAs.id
LEFT JOIN asset_groups AS ag ON ag.id = ada.asset_group_id
LEFT JOIN assets_asset_fleets AS aafleet ON aafleet.transam_asset_id = transamAs.id
LEFT JOIN asset_fleets AS fleets ON fleets.id = aafleet.asset_fleet_id
LEFT JOIN tam_groups AS tg ON tg.organization_id = transamAs.organization_id;


DROP VIEW if exists service_vehicle_asset_table_views;

CREATE OR REPLACE SQL SECURITY INVOKER VIEW service_vehicle_asset_table_views AS
SELECT
	sv.id,
	sv.id AS 'service_vehicle_id',
    transamAs.organization_id AS 'organization_id',
    transamAs.asset_subtype_id AS 'asset_subtype_id',
    transamAs.transam_assetible_id AS 'asset_type_id',
    transamAs.asset_tag AS 'asset_tag',
    transamAs.object_key AS 'object_key',
    transitAs.fta_asset_class_id,
	mrAev.asset_event_id AS 'most_recent_asset_event',
    rae_condition.asset_event_id AS 'condition_event_id',
    rae_service_status.asset_event_id AS 'service_status_event_id',
    rae_rebuild.asset_event_id AS 'rebuild_event_id',
    rae_mileage.asset_event_id AS 'mileage_event_id',
    rae_early_replacement_status.asset_event_id AS 'early_replacement_status_event_id',
    ag.id AS 'asset_group_id',
    fleets.id AS 'asset_fleet_id',
    fleets.ntd_id AS 'ntd_id'
FROM service_vehicles AS sv
LEFT JOIN transit_assets AS transitAs ON transitAs.transit_assetible_id = sv.id
	AND transitAs.transit_assetible_type = 'ServiceVehicle'
LEFT JOIN transam_assets AS transamAs ON transamAs.transam_assetible_id = transitAs.id
	AND transamAs.transam_assetible_type = 'TransitAsset'
LEFT JOIN most_recent_asset_event_view AS mrAev ON mrAev.transam_asset_id = transamAs.id
LEFT JOIN recent_asset_events_for_type_view AS rae_condition ON rae_condition.transam_asset_id = transamAs.id
	AND rae_condition.asset_event_type_id = 1
LEFT JOIN recent_asset_events_for_type_view AS rae_maintenance ON rae_maintenance.transam_asset_id = transamAs.id
	AND rae_maintenance.asset_event_type_id = 2
LEFT JOIN recent_asset_events_for_type_view AS rae_service_status ON rae_service_status.transam_asset_id = transamAs.id
	AND rae_service_status.asset_event_type_id = 6
LEFT JOIN recent_asset_events_for_type_view AS rae_rebuild ON rae_rebuild.transam_asset_id = transamAs.id
	AND rae_rebuild.asset_event_type_id = 8
LEFT JOIN recent_asset_events_for_type_view AS rae_mileage ON rae_mileage.transam_asset_id = transamAs.id
	AND rae_mileage.asset_event_type_id = 10
LEFT JOIN recent_asset_events_for_type_view AS rae_early_replacement_status ON rae_early_replacement_status.transam_asset_id = transamAs.id
	AND rae_early_replacement_status.asset_event_type_id = 19
LEFT JOIN asset_groups_assets AS ada ON ada.transam_asset_id = transamAs.id
LEFT JOIN asset_groups AS ag ON ag.id = ada.asset_group_id
LEFT JOIN assets_asset_fleets AS aafleet ON aafleet.transam_asset_id = transamAs.id
LEFT JOIN asset_fleets AS fleets ON fleets.id = aafleet.asset_fleet_id
LEFT JOIN tam_groups AS tg ON tg.organization_id = transamAs.organization_id;

DROP VIEW if exists capital_equipment_asset_table_views;

CREATE OR REPLACE SQL SECURITY INVOKER VIEW capital_equipment_asset_table_views AS
SELECT
	transitAs.id,
	transitAs.id AS 'capital_equipment_id',
    transamAs.organization_id AS 'organization_id',
    transamAs.asset_subtype_id AS 'asset_subtype_id',
    transamAs.transam_assetible_id AS 'asset_type_id',
    transamAs.asset_tag AS 'asset_tag',
    transamAs.object_key AS 'object_key',
    transitAs.fta_asset_class_id,
    mrAev.asset_event_id AS 'most_recent_asset_event',
	rae_condition.asset_event_id AS 'condition_event_id',
    rae_service_status.asset_event_id AS 'service_status_event_id',
    rae_rebuild.asset_event_id AS 'rebuild_event_id',
    rae_mileage.asset_event_id AS 'mileage_event_id',
    rae_early_replacement_status.asset_event_id AS 'early_replacement_status_event_id',
    ag.id AS 'asset_group_id',
    fleets.id AS 'asset_fleet_id',
    fleets.ntd_id AS 'ntd_id'
FROM transit_assets AS transitAs
LEFT JOIN transam_assets AS transamAs ON transamAs.transam_assetible_id = transitAs.id
	AND transamAs.transam_assetible_type = 'TransitAsset'
LEFT JOIN most_recent_asset_event_view AS mrAev ON mrAev.transam_asset_id = transamAs.id
LEFT JOIN recent_asset_events_for_type_view AS rae_condition ON rae_condition.transam_asset_id = transamAs.id
	AND rae_condition.asset_event_type_id = 1
LEFT JOIN recent_asset_events_for_type_view AS rae_maintenance ON rae_maintenance.transam_asset_id = transamAs.id
	AND rae_maintenance.asset_event_type_id = 2
LEFT JOIN recent_asset_events_for_type_view AS rae_service_status ON rae_service_status.transam_asset_id = transamAs.id
	AND rae_service_status.asset_event_type_id = 6
LEFT JOIN recent_asset_events_for_type_view AS rae_rebuild ON rae_rebuild.transam_asset_id = transamAs.id
	AND rae_rebuild.asset_event_type_id = 8
LEFT JOIN recent_asset_events_for_type_view AS rae_mileage ON rae_mileage.transam_asset_id = transamAs.id
	AND rae_mileage.asset_event_type_id = 10
LEFT JOIN recent_asset_events_for_type_view AS rae_early_replacement_status ON rae_early_replacement_status.transam_asset_id = transamAs.id
	AND rae_early_replacement_status.asset_event_type_id = 19
LEFT JOIN asset_groups_assets AS ada ON ada.transam_asset_id = transamAs.id
LEFT JOIN asset_groups AS ag ON ag.id = ada.asset_group_id
LEFT JOIN assets_asset_fleets AS aafleet ON aafleet.transam_asset_id = transamAs.id
LEFT JOIN asset_fleets AS fleets ON fleets.id = aafleet.asset_fleet_id
LEFT JOIN tam_groups AS tg ON tg.organization_id = transamAs.organization_id;

DROP VIEW if exists facility_primary_asset_table_views;

CREATE OR REPLACE SQL SECURITY INVOKER VIEW facility_primary_asset_table_views AS
SELECT
	f.id,
	f.id AS 'facility_id',
    transamAs.organization_id AS 'organization_id',
    transamAs.asset_subtype_id AS 'asset_subtype_id',
    transamAs.transam_assetible_id AS 'asset_type_id',
    transamAs.asset_tag AS 'asset_tag',
    transamAs.object_key AS 'object_key',
    transitAs.fta_asset_class_id,
    transamAs.transam_assetible_type,
    mrAev.asset_event_id AS 'most_recent_asset_event',
    rae_condition.asset_event_id AS 'condition_event_id',
    rae_service_status.asset_event_id AS 'service_status_event_id',
    rae_rebuild.asset_event_id AS 'rebuild_event_id',
    rae_mileage.asset_event_id AS 'mileage_event_id',
    rae_early_replacement_status.asset_event_id AS 'early_replacement_status_event_id',
    ag.id AS 'asset_group_id'
FROM facilities AS f
LEFT JOIN transit_assets AS transitAs ON transitAs.transit_assetible_type = 'Facility'  AND transit_assetible_id = f.id
LEFT JOIN transam_assets AS transamAs ON transamAs.transam_assetible_id = transitAs.id
LEFT JOIN most_recent_asset_event_view AS mrAev ON mrAev.transam_asset_id = transamAs.id
LEFT JOIN recent_asset_events_for_type_view AS rae_condition ON rae_condition.transam_asset_id = transamAs.id
	AND rae_condition.asset_event_type_id = 1
LEFT JOIN recent_asset_events_for_type_view AS rae_maintenance ON rae_maintenance.transam_asset_id = transamAs.id
	AND rae_maintenance.asset_event_type_id = 2
LEFT JOIN recent_asset_events_for_type_view AS rae_service_status ON rae_service_status.transam_asset_id = transamAs.id
	AND rae_service_status.asset_event_type_id = 6
LEFT JOIN recent_asset_events_for_type_view AS rae_rebuild ON rae_rebuild.transam_asset_id = transamAs.id
	AND rae_rebuild.asset_event_type_id = 8
LEFT JOIN recent_asset_events_for_type_view AS rae_mileage ON rae_mileage.transam_asset_id = transamAs.id
	AND rae_mileage.asset_event_type_id = 10
LEFT JOIN recent_asset_events_for_type_view AS rae_early_replacement_status ON rae_early_replacement_status.transam_asset_id = transamAs.id
	AND rae_early_replacement_status.asset_event_type_id = 19
    LEFT JOIN asset_groups_assets AS ada ON ada.transam_asset_id = transamAs.id
LEFT JOIN asset_groups AS ag ON ag.id = ada.asset_group_id;

DROP VIEW if exists infrastructure_asset_table_views;

CREATE OR REPLACE SQL SECURITY INVOKER VIEW infrastructure_asset_table_views AS
SELECT
	i.id,
	i.id AS 'infrastructure_id',
    transamAs.organization_id AS 'organization_id',
    transamAs.asset_subtype_id AS 'asset_subtype_id',
    transamAs.transam_assetible_id AS 'asset_type_id',
    transamAs.asset_tag AS 'asset_tag',
    transamAs.object_key AS 'object_key',
    transitAs.fta_asset_class_id,
    transamAs.transam_assetible_type,
    mrAev.asset_event_id AS 'most_recent_asset_event',
    rae_condition.asset_event_id AS 'condition_event_id',
    rae_service_status.asset_event_id AS 'service_status_event_id',
    rae_rebuild.asset_event_id AS 'rebuild_event_id',
    rae_mileage.asset_event_id AS 'mileage_event_id',
    rae_early_replacement_status.asset_event_id AS 'early_replacement_status_event_id',
    ag.id AS 'asset_group_id'
FROM infrastructures AS i
LEFT JOIN transit_assets AS transitAs ON transitAs.transit_assetible_type = 'Infrastructure'  AND transit_assetible_id = i.id
LEFT JOIN transam_assets AS transamAs ON transamAs.transam_assetible_id = transitAs.id
LEFT JOIN most_recent_asset_event_view AS mrAev ON mrAev.transam_asset_id = transamAs.id
LEFT JOIN recent_asset_events_for_type_view AS rae_condition ON rae_condition.transam_asset_id = transamAs.id
	AND rae_condition.asset_event_type_id = 1
LEFT JOIN recent_asset_events_for_type_view AS rae_maintenance ON rae_maintenance.transam_asset_id = transamAs.id
	AND rae_maintenance.asset_event_type_id = 2
LEFT JOIN recent_asset_events_for_type_view AS rae_service_status ON rae_service_status.transam_asset_id = transamAs.id
	AND rae_service_status.asset_event_type_id = 6
LEFT JOIN recent_asset_events_for_type_view AS rae_rebuild ON rae_rebuild.transam_asset_id = transamAs.id
	AND rae_rebuild.asset_event_type_id = 8
LEFT JOIN recent_asset_events_for_type_view AS rae_mileage ON rae_mileage.transam_asset_id = transamAs.id
	AND rae_mileage.asset_event_type_id = 10
LEFT JOIN recent_asset_events_for_type_view AS rae_early_replacement_status ON rae_early_replacement_status.transam_asset_id = transamAs.id
	AND rae_early_replacement_status.asset_event_type_id = 19
    LEFT JOIN asset_groups_assets AS ada ON ada.transam_asset_id = transamAs.id
LEFT JOIN asset_groups AS ag ON ag.id = ada.asset_group_id
