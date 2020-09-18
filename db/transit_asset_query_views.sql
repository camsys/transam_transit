-- Full list of database views to serve as data source for Query Tool
-- ----------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------
DROP VIEW if exists service_vehicle_vin_view;
CREATE OR REPLACE VIEW service_vehicle_vin_view AS
    select transam_assets.id as transam_asset_id, serial_numbers.identification as vin from serial_numbers
    inner join transam_assets 
    on transam_assets.id = serial_numbers.identifiable_id and serial_numbers.identifiable_type = 'TransamAsset'
    inner join transit_assets
    on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
    inner join service_vehicles
    on transit_assets.transit_assetible_id = service_vehicles.id and transit_assets.transit_assetible_type = 'ServiceVehicle';

DROP VIEW if exists serial_identification_view;
CREATE OR REPLACE VIEW serial_identification_view AS
    select transam_assets.id as transam_asset_id, serial_numbers.identification as serial_identification from serial_numbers
    inner join transam_assets 
    on transam_assets.id = serial_numbers.identifiable_id and serial_numbers.identifiable_type = 'TransamAsset'
    inner join transit_assets
    on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
    where transit_assets.fta_asset_class_id IN 
    (SELECT fta_asset_classes.id FROM fta_asset_classes WHERE fta_asset_classes.class_name = 'CapitalEquipment');

DROP VIEW if exists dual_fuel_type_view;
CREATE OR REPLACE VIEW dual_fuel_type_view AS
    select dual_fuel_types.id, concat(primary_fuel_types.name, '-', secondary_fuel_types.name) as fuel_type_name, dual_fuel_types.active
    from dual_fuel_types
    left join fuel_types as primary_fuel_types 
    on primary_fuel_types.id = dual_fuel_types.primary_fuel_type_id
    left join fuel_types as secondary_fuel_types 
    on secondary_fuel_types.id = dual_fuel_types.secondary_fuel_type_id;

DROP VIEW if exists transit_asset_types_view;
CREATE OR REPLACE VIEW transit_asset_types_view AS
    SELECT ta.id, concat(ta.fta_type_type, '_', ta.fta_type_id) as fta_type_type_id,concat(COALESCE(fvt.name, ''), COALESCE(fsvt.name, ''), COALESCE(fft.name, ''), COALESCE(fet.name, ''),  COALESCE(fgt.name, ''),  COALESCE(ftrt.name, ''),  COALESCE(fpst.name, '')) as fta_type FROM transit_assets as ta 
    left join fta_vehicle_types as fvt on fvt.id = ta.fta_type_id and ta.fta_type_type = 'FtaVehicleType'
    left join fta_support_vehicle_types as fsvt on fsvt.id = ta.fta_type_id and ta.fta_type_type = 'FtaSupportVehicleType'
    left join fta_facility_types as fft on fft.id = ta.fta_type_id and ta.fta_type_type = 'FtaFacilityType'
    left join fta_equipment_types as fet on fet.id = ta.fta_type_id and ta.fta_type_type = 'FtaEquipmentType'
    left join fta_guideway_types as fgt on fgt.id = ta.fta_type_id and ta.fta_type_type = 'FtaGuidewayType'
    left join fta_track_types as ftrt on ftrt.id = ta.fta_type_id and ta.fta_type_type = 'FtaTrackType'
    left join fta_power_signal_types as fpst on fpst.id = ta.fta_type_id and ta.fta_type_type = 'FtaPowerSignalType';

DROP VIEW if exists transit_assets_direct_capital_responsibility_view;
CREATE OR REPLACE VIEW transit_assets_direct_capital_responsibility_view AS
    select transam_assets.id as transam_asset_id, (case when pcnt_capital_responsibility > 0 then true else false end) 
    as direct_captial_responsibility 
    from transit_assets
    inner join transam_assets 
    on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset';

DROP VIEW if exists transit_assets_category_view;
CREATE OR REPLACE VIEW transit_assets_category_view AS
    select transam_assets.id as transam_asset_id, (case when component_subtypes.name is not NULL then 'Sub-Component' when component_types.name is not NULL then 'Component' ELSE 'Primary' END) as categorization_name,
    (case when component_subtypes.name is not NULL then component_subtypes.name when component_types.name is not NULL then component_types.name ELSE NULL END) as component_type_subtype_name
    FROM transam_assets
    LEFT JOIN transit_assets ON transit_assets.id = transam_assets.transam_assetible_id
    LEFT JOIN facilities on facilities.id = transit_assets.transit_assetible_id and transit_assets.transit_assetible_type = 'Facility'
    LEFT JOIN infrastructures on infrastructures.id = transit_assets.transit_assetible_id and transit_assets.transit_assetible_type = 'Infrastructure'
    LEFT JOIN transit_components ON transit_components.id = transit_assets.transit_assetible_id
      AND transit_assets.transit_assetible_type = 'TransitComponent'
    LEFT JOIN component_types ON component_types.id = transit_components.component_type_id 
    LEFT JOIN component_subtypes on component_subtypes.id = transit_components.component_subtype_id 
    WHERE transam_assets.transam_assetible_type = 'TransitAsset' AND ( facilities.id > 0 OR infrastructures.id > 0 OR transit_assets.fta_asset_class_id IN ( SELECT fta_asset_classes.id FROM fta_asset_classes WHERE fta_asset_classes.class_name IN ('Facility', 'Guideway', 'PowerSignal', 'Track')));

DROP VIEW if exists transit_component_subtype_measurement_view;
CREATE OR REPLACE VIEW transit_component_subtype_measurement_view AS
    select 
      transam_assets.id as transam_asset_id, transit_components.infrastructure_measurement as component_subtype_measurement,
      transit_components.infrastructure_measurement_unit as component_subtype_measurement_unit
    from transit_components
    inner join transit_assets on transit_assets.transit_assetible_id = transit_components.id
    and transit_assets.transit_assetible_type = 'TransitComponent'
    inner join transam_assets 
    on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
    left join component_subtypes on component_subtypes.id = transit_components.component_subtype_id
    where component_subtypes.name in ('Sub-Ballast', 'Blanket', 'Subgrade');

DROP VIEW if exists infrastructure_measurement_rail_culverts_type_view;
CREATE OR REPLACE VIEW infrastructure_measurement_rail_culverts_type_view AS
    select 
      transam_assets.id as transam_asset_id, transit_components.infrastructure_measurement as rail_culverts_measurement,
      transit_components.infrastructure_measurement_unit as rail_culverts_measurement_unit
    from transit_components
    inner join transit_assets on transit_assets.transit_assetible_id = transit_components.id
    and transit_assets.transit_assetible_type = 'TransitComponent'
    inner join transam_assets 
    on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
    left join component_types on component_types.id = transit_components.component_type_id
    where component_types.name in ('Rail', 'Culverts');

DROP VIEW if exists transit_component_spikes_screws_subtype_view;
CREATE OR REPLACE VIEW transit_component_spikes_screws_subtype_view AS
  select transam_assets.id as transam_asset_id, transit_components.component_element_id as spikes_screws_subtype_id from transit_components
  inner join transit_assets on transit_assets.transit_assetible_id = transit_components.id
  and transit_assets.transit_assetible_type = 'TransitComponent'
  inner join transam_assets 
  on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
  left join component_elements on transit_components.component_element_id = component_elements.id
  left join component_subtypes on component_elements.parent_id = component_subtypes.id and component_elements.parent_type = 'ComponentSubtype'
  where component_subtypes.name = 'Spikes & Screws';

DROP VIEW if exists transit_component_supports_subtype_view;
CREATE OR REPLACE VIEW transit_component_supports_subtype_view AS
  select transam_assets.id as transam_asset_id, transit_components.component_element_id as supports_subtype_id from transit_components
  inner join transit_assets on transit_assets.transit_assetible_id = transit_components.id
  and transit_assets.transit_assetible_type = 'TransitComponent'
  inner join transam_assets 
  on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
  left join component_elements on transit_components.component_element_id = component_elements.id
  left join component_subtypes on component_elements.parent_id = component_subtypes.id and component_elements.parent_type = 'ComponentSubtype'
  where component_subtypes.name = 'Supports';

DROP VIEW if exists transit_component_sub_ballast_subtype_view;
CREATE OR REPLACE VIEW transit_component_sub_ballast_subtype_view AS
  select transam_assets.id as transam_asset_id, transit_components.component_element_id as sub_ballast_subtype_id from transit_components
  inner join transit_assets on transit_assets.transit_assetible_id = transit_components.id
  and transit_assets.transit_assetible_type = 'TransitComponent'
  inner join transam_assets 
  on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
  left join component_subtypes on transit_components.component_element_id = component_elements.id
  left join component_subtypes on component_elements.parent_id = component_subtypes.id and component_elements.parent_type = 'ComponentSubtype'
  where component_subtypes.name = 'Sub-Ballast';

DROP VIEW if exists transit_component_blanket_subtype_view;
CREATE OR REPLACE VIEW transit_component_blanket_subtype_view AS
  select transam_assets.id as transam_asset_id, transit_components.component_element_id as blanket_subtype_id from transit_components
  inner join transit_assets on transit_assets.transit_assetible_id = transit_components.id
  and transit_assets.transit_assetible_type = 'TransitComponent'
  inner join transam_assets 
  on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
  left join component_elements on transit_components.component_element_id = component_elements.id
  left join component_subtypes on component_elements.parent_id = component_subtypes.id and component_elements.parent_type = 'ComponentSubtype'
  where component_subtypes.name = 'Blanket';

DROP VIEW if exists transit_component_subgrade_subtype_view;
CREATE OR REPLACE VIEW transit_component_subgrade_subtype_view AS
  select transam_assets.id as transam_asset_id, transit_components.component_element_id as subgrade_subtype_id from transit_components
  inner join transit_assets on transit_assets.transit_assetible_id = transit_components.id
  and transit_assets.transit_assetible_type = 'TransitComponent'
  inner join transam_assets 
  on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
  left join component_elements on transit_components.component_element_id = component_elements.id
  left join component_subtypes on component_elements.parent_id = component_subtypes.id and component_elements.parent_type = 'ComponentSubtype'
  where component_subtypes.name = 'Subgrade';

DROP VIEW if exists transit_component_mounting_subtype_view;
CREATE OR REPLACE VIEW transit_component_mounting_subtype_view AS
  select transam_assets.id as transam_asset_id, transit_components.component_element_id as mounting_subtype_id from transit_components
  inner join transit_assets on transit_assets.transit_assetible_id = transit_components.id
  and transit_assets.transit_assetible_type = 'TransitComponent'
  inner join transam_assets 
  on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
  left join component_elements on transit_components.component_element_id = component_elements.id
  left join component_subtypes on component_elements.parent_id = component_subtypes.id and component_elements.parent_type = 'ComponentSubtype'
  where component_subtypes.name = 'Mounting';

DROP VIEW if exists transit_component_signals_subtype_view;
CREATE OR REPLACE VIEW transit_component_signals_subtype_view AS
  select transam_assets.id as transam_asset_id, transit_components.component_element_id as signals_subtype_id from transit_components
  inner join transit_assets on transit_assets.transit_assetible_id = transit_components.id
  and transit_assets.transit_assetible_type = 'TransitComponent'
  inner join transam_assets 
  on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
  left join component_elements on transit_components.component_element_id = component_elements.id
  left join component_subtypes on component_elements.parent_id = component_subtypes.id and component_elements.parent_type = 'ComponentSubtype'
  where component_subtypes.name = 'Signals';

DROP VIEW if exists transit_component_rail_subtype_view;
CREATE OR REPLACE VIEW transit_component_rail_subtype_view AS
  select transam_assets.id as transam_asset_id, transit_components.component_element_id as rail_subtype_id from transit_components
  inner join transit_assets on transit_assets.transit_assetible_id = transit_components.id
  and transit_assets.transit_assetible_type = 'TransitComponent'
  inner join transam_assets 
  on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
  left join component_elements on transit_components.component_element_id = component_elements.id
  left join component_types on component_elements.parent_id = component_types.id and component_elements.parent_type = 'ComponentType'
  where component_types.name = 'Rail';

DROP VIEW if exists transit_component_ties_subtype_view;  
CREATE OR REPLACE VIEW transit_component_ties_subtype_view AS
  select transam_assets.id as transam_asset_id, transit_components.component_element_id as ties_subtype_id from transit_components
  inner join transit_assets on transit_assets.transit_assetible_id = transit_components.id
  and transit_assets.transit_assetible_type = 'TransitComponent'
  inner join transam_assets 
  on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
  left join component_elements on transit_components.component_element_id = component_elements.id
  left join component_types on component_elements.parent_id = component_types.id and component_elements.parent_type = 'ComponentType'
  where component_types.name = 'Ties';

DROP VIEW if exists transit_component_field_welds_subtype_view;
CREATE OR REPLACE VIEW transit_component_field_welds_subtype_view AS
  select transam_assets.id as transam_asset_id, transit_components.component_element_id as field_welds_subtype_id from transit_components
  inner join transit_assets on transit_assets.transit_assetible_id = transit_components.id
  and transit_assets.transit_assetible_type = 'TransitComponent'
  inner join transam_assets 
  on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
  left join component_elements on transit_components.component_element_id = component_elements.id
  left join component_types on component_elements.parent_id = component_types.id and component_elements.parent_type = 'ComponentType'
  where component_types.name = 'Field Welds';

DROP VIEW if exists transit_component_joints_subtype_view;
CREATE OR REPLACE VIEW transit_component_joints_subtype_view AS
  select transam_assets.id as transam_asset_id, transit_components.component_element_id as joints_subtype_id from transit_components
  inner join transit_assets on transit_assets.transit_assetible_id = transit_components.id
  and transit_assets.transit_assetible_type = 'TransitComponent'
  inner join transam_assets 
  on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
  left join component_elements on transit_components.component_element_id = component_elements.id
  left join component_types on component_elements.parent_id = component_types.id and component_elements.parent_type = 'ComponentType'
  where component_types.name = 'Joints';

DROP VIEW if exists transit_component_ballast_subtype_view;
CREATE OR REPLACE VIEW transit_component_ballast_subtype_view AS
  select transam_assets.id as transam_asset_id, transit_components.component_element_id as ballast_subtype_id from transit_components
  inner join transit_assets on transit_assets.transit_assetible_id = transit_components.id
  and transit_assets.transit_assetible_type = 'TransitComponent'
  inner join transam_assets 
  on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
  left join component_elements on transit_components.component_element_id = component_elements.id
  left join component_types on component_elements.parent_id = component_types.id and component_elements.parent_type = 'ComponentType'
  where component_types.name = 'Ballast';

DROP VIEW if exists transit_component_culverts_subtype_view;
CREATE OR REPLACE VIEW transit_component_culverts_subtype_view AS
  select transam_assets.id as transam_asset_id, transit_components.component_element_id as culverts_subtype_id from transit_components
  inner join transit_assets on transit_assets.transit_assetible_id = transit_components.id
  and transit_assets.transit_assetible_type = 'TransitComponent'
  inner join transam_assets 
  on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
  left join component_elements on transit_components.component_element_id = component_elements.id
  left join component_types on component_elements.parent_id = component_types.id and component_elements.parent_type = 'ComponentType'
  where component_types.name = 'Culverts';

DROP VIEW if exists transit_component_surface_deck_subtype_view;
CREATE OR REPLACE VIEW transit_component_surface_deck_subtype_view AS
  select transam_assets.id as transam_asset_id, transit_components.component_element_id as surface_deck_subtype_id from transit_components
  inner join transit_assets on transit_assets.transit_assetible_id = transit_components.id
  and transit_assets.transit_assetible_type = 'TransitComponent'
  inner join transam_assets 
  on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
  left join component_elements on transit_components.component_element_id = component_elements.id
  left join component_types on component_elements.parent_id = component_types.id and component_elements.parent_type = 'ComponentType'
  where component_types.name = 'Surface / Deck';

DROP VIEW if exists transit_component_substructure_subtype_view;
CREATE OR REPLACE VIEW transit_component_substructure_subtype_view AS
  select transam_assets.id as transam_asset_id, transit_components.component_element_id as substructure_subtype_id from transit_components
  inner join transit_assets on transit_assets.transit_assetible_id = transit_components.id
  and transit_assets.transit_assetible_type = 'TransitComponent'
  inner join transam_assets 
  on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
  left join component_elements on transit_components.component_element_id = component_elements.id
  left join component_types on component_elements.parent_id = component_types.id and component_elements.parent_type = 'ComponentType'
  where component_types.name = 'Substructure';

DROP VIEW if exists transit_component_superstructure_subtype_view;
CREATE OR REPLACE VIEW transit_component_superstructure_subtype_view AS
  select transam_assets.id as transam_asset_id, transit_components.component_element_id as superstructure_subtype_id from transit_components
  inner join transit_assets on transit_assets.transit_assetible_id = transit_components.id
  and transit_assets.transit_assetible_type = 'TransitComponent'
  inner join transam_assets 
  on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
  left join component_elements on transit_components.component_element_id = component_elements.id
  left join component_types on component_elements.parent_id = component_types.id and component_elements.parent_type = 'ComponentType'
  where component_types.name = 'Superstructure';

DROP VIEW if exists transit_component_perimeter_subtype_view;
CREATE OR REPLACE VIEW transit_component_perimeter_subtype_view AS
  select transam_assets.id as transam_asset_id, transit_components.component_element_id as perimeter_subtype_id from transit_components
  inner join transit_assets on transit_assets.transit_assetible_id = transit_components.id
  and transit_assets.transit_assetible_type = 'TransitComponent'
  inner join transam_assets 
  on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
  left join component_elements on transit_components.component_element_id = component_elements.id
  left join component_types on component_elements.parent_id = component_types.id and component_elements.parent_type = 'ComponentType'
  where component_types.name = 'Perimeter';

DROP VIEW if exists transit_component_contact_system_subtype_view;
CREATE OR REPLACE VIEW transit_component_contact_system_subtype_view AS
  select transam_assets.id as transam_asset_id, transit_components.component_element_id as contact_system_subtype_id from transit_components
  inner join transit_assets on transit_assets.transit_assetible_id = transit_components.id
  and transit_assets.transit_assetible_type = 'TransitComponent'
  inner join transam_assets
  on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
  left join component_elements on transit_components.component_element_id = component_elements.id
  left join component_types on component_elements.parent_id = component_types.id and component_elements.parent_type = 'ComponentType'
  where component_types.name = 'Contact System';

DROP VIEW if exists transit_component_structure_subtype_view;
CREATE OR REPLACE VIEW transit_component_structure_subtype_view AS
  select transam_assets.id as transam_asset_id, transit_components.component_element_id as structure_subtype_id from transit_components
  inner join transit_assets on transit_assets.transit_assetible_id = transit_components.id
  and transit_assets.transit_assetible_type = 'TransitComponent'
  inner join transam_assets
  on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
  left join component_elements on transit_components.component_element_id = component_elements.id
  left join component_types on component_elements.parent_id = component_types.id and component_elements.parent_type = 'ComponentType'
  where component_types.name = 'Structure';

DROP VIEW if exists transit_component_ties_material_view;
CREATE OR REPLACE VIEW transit_component_ties_material_view AS
  select transam_assets.id as transam_asset_id, transit_components.component_material_id as ties_material_type_id from transit_components
  inner join transit_assets on transit_assets.transit_assetible_id = transit_components.id
  and transit_assets.transit_assetible_type = 'TransitComponent'
  inner join transam_assets
  on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
  left join component_types on transit_components.component_type_id = component_types.id
  left join component_materials on component_materials.component_type_id = component_types.id
  where component_types.name = 'Ties';

DROP VIEW if exists transit_component_surface_deck_material_view;
CREATE OR REPLACE VIEW transit_component_surface_deck_material_view AS
  select transam_assets.id as transam_asset_id, transit_components.component_material_id as surface_deck_material_type_id from transit_components
  inner join transit_assets on transit_assets.transit_assetible_id = transit_components.id
  and transit_assets.transit_assetible_type = 'TransitComponent'
  inner join transam_assets
  on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
  left join component_types on transit_components.component_type_id = component_types.id
  left join component_materials on component_materials.component_type_id = component_types.id
  where component_types.name = 'Surface / Deck';

DROP VIEW if exists transit_component_substructure_material_view;
CREATE OR REPLACE VIEW transit_component_substructure_material_view AS
  select transam_assets.id as transam_asset_id, transit_components.component_material_id as substructure_material_type_id from transit_components
  inner join transit_assets on transit_assets.transit_assetible_id = transit_components.id
  and transit_assets.transit_assetible_type = 'TransitComponent'
  inner join transam_assets
  on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
  left join component_types on transit_components.component_type_id = component_types.id
  left join component_materials on component_materials.component_type_id = component_types.id
  where component_types.name = 'Substructure';

DROP VIEW if exists transit_component_superstructure_material_view;
CREATE OR REPLACE VIEW transit_component_superstructure_material_view AS
  select transam_assets.id as transam_asset_id, transit_components.component_material_id as superstructure_material_type_id from transit_components
  inner join transit_assets on transit_assets.transit_assetible_id = transit_components.id
  and transit_assets.transit_assetible_type = 'TransitComponent'
  inner join transam_assets
  on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
  left join component_types on transit_components.component_type_id = component_types.id
  left join component_materials on component_materials.component_type_id = component_types.id
  where component_types.name = 'Superstructure';

DROP VIEW if exists transam_vehicle_usage_codes_view;
CREATE OR REPLACE VIEW transam_vehicle_usage_codes_view AS
    select vucae.base_transam_asset_id as transam_asset_id, Max(asset_events_vehicle_usage_codes.vehicle_usage_code_id) as vehicle_usage_code_id from transam_assets
    left join asset_events as vucae on vucae.transam_asset_id = transam_assets.id left join asset_events_vehicle_usage_codes on vucae.id = asset_events_vehicle_usage_codes.asset_event_id
    group by vucae.base_transam_asset_id;

DROP VIEW if exists transit_asset_assets_features_view;
CREATE OR REPLACE VIEW transit_asset_assets_features_view AS
  SELECT transam_assets.id AS transam_asset_id, facility_features.code AS features_code
  FROM assets_facility_features
  INNER JOIN facility_features ON assets_facility_features.facility_feature_id = facility_features.id
  INNER JOIN facilities ON assets_facility_features.transam_asset_id = facilities.id
  INNER JOIN transit_assets ON transit_assetible_id = facilities.id AND transit_assetible_type = 'Facility'
  INNER JOIN transam_assets ON transam_assetible_id = transit_assets.id AND transam_assetible_type = 'TransitAsset'
  UNION ALL
  SELECT transam_assets.id AS transam_asset_id, vehicle_features.code
  FROM assets_vehicle_features
  INNER JOIN vehicle_features ON assets_vehicle_features.vehicle_feature_id = vehicle_features.id
  INNER JOIN revenue_vehicles ON assets_vehicle_features.transam_asset_id = revenue_vehicles.id
  INNER JOIN service_vehicles ON service_vehiclible_id = revenue_vehicles.id AND service_vehiclible_type = 'RevenueVehicle'
  INNER JOIN transit_assets ON transit_assetible_id = service_vehicles.id AND transit_assetible_type = 'ServiceVehicle'
  INNER JOIN transam_assets ON transam_assetible_id = transit_assets.id AND transam_assetible_type = 'TransitAsset';

DROP VIEW if exists transit_asset_features_view;
CREATE OR REPLACE VIEW transit_asset_features_view AS
    SELECT 'Facility' AS `type`, `id`, `name`, `code`, `active` FROM facility_features
    UNION ALL SELECT 'RevenueVehicle' AS `type`, `id`, `name`, `code`, `active` FROM vehicle_features;

DROP VIEW if exists track_most_recent_performance_restrictions_period_view;
CREATE OR REPLACE VIEW track_most_recent_performance_restrictions_period_view AS
  SELECT mrae.asset_event_id, mrae.base_transam_asset_id, IF(ae.period_length IS NULL, "Until Removed", "Set Length") AS period, ae.period_length, ae.period_length_unit
  FROM query_tool_most_recent_asset_events_for_type_view AS mrae
  LEFT JOIN asset_events AS ae ON ae.id = mrae.asset_event_id
  LEFT JOIN transam_assets AS tma ON mrae.base_transam_asset_id = tma.id
  LEFT JOIN transit_assets AS tta ON tta.id = tma.transam_assetible_id AND tma.transam_assetible_type = 'TransitAsset'
  LEFT JOIN fta_asset_classes AS fac ON fac.id = tta.fta_asset_class_id
  WHERE ae.id = mrae.asset_event_id AND fac.name = 'Track' AND mrae.asset_event_name = 'Performance restrictions';

CREATE OR REPLACE VIEW location_transam_assets_view AS
      SELECT transam_assets.organization_id, transam_assets.id AS location_id, transam_assets.asset_tag, facilities.facility_name, transam_assets.description,
CONCAT(asset_tag, IF(facility_name IS NOT NULL OR description IS NOT NULL, ' : ', ''), IFNULL(facility_name,description)) AS location_name
FROM transam_assets
INNER JOIN `transit_assets` ON `transam_assets`.`transam_assetible_id` = `transit_assets`.`id` AND `transam_assets`.`transam_assetible_type` = 'TransitAsset'
LEFT JOIN `facilities` ON `transit_assets`.`transit_assetible_id` = `facilities`.`id` AND `transit_assets`.`transit_assetible_type` = 'Facility'
WHERE transam_assets.id IN (SELECT DISTINCT location_id FROM transam_assets WHERE location_id IS NOT NULL)

CREATE OR REPLACE VIEW parent_transam_assets_view AS
SELECT transam_assets.organization_id, transam_assets.object_key as parent_id, transam_assets.asset_tag, facilities.facility_name, transam_assets.description,
CONCAT(asset_tag, IF(facility_name IS NOT NULL OR description IS NOT NULL, ' : ', ''), IFNULL(facility_name,description)) AS parent_name
FROM transam_assets
INNER JOIN `transit_assets` ON `transam_assets`.`transam_assetible_id` = `transit_assets`.`id` AND `transam_assets`.`transam_assetible_type` = 'TransitAsset'
LEFT JOIN `facilities` ON `transit_assets`.`transit_assetible_id` = `facilities`.`id` AND `transit_assets`.`transit_assetible_type` = 'Facility'
WHERE transam_assets.id IN (SELECT DISTINCT parent_id FROM transam_assets INNER JOIN `transit_assets` ON `transam_assets`.`transam_assetible_id` = `transit_assets`.`id` AND `transam_assets`.`transam_assetible_type` = 'TransitAsset' WHERE parent_id IS NOT NULL AND fta_asset_category_id != 4)
UNION
SELECT transam_assets.organization_id, transam_assets.object_key as parent_id, transam_assets.asset_tag, NULL, transam_assets.description,
CONCAT(asset_tag, IF(description IS NOT NULL, ' : ', ''), description) AS parent_name
FROM transam_assets
INNER JOIN `transit_assets` ON `transam_assets`.`transam_assetible_id` = `transit_assets`.`id` AND `transam_assets`.`transam_assetible_type` = 'TransitAsset'
INNER JOIN `infrastructures` ON `transit_assets`.`transit_assetible_id` = `infrastructures`.`id` AND `transit_assets`.`transit_assetible_type` = 'Infrastructure'
WHERE transam_assets.id IN (SELECT DISTINCT parent_id FROM transam_assets INNER JOIN `transit_assets` ON `transam_assets`.`transam_assetible_id` = `transit_assets`.`id` AND `transam_assets`.`transam_assetible_type` = 'TransitAsset' WHERE parent_id IS NOT NULL AND fta_asset_category_id = 4)

CREATE OR REPLACE VIEW infrastructures_object_key_view AS
    SELECT DISTINCT infrastructures.id AS id, transam_assets.object_key AS object_key FROM transam_assets INNER JOIN `transit_assets` ON `transam_assets`.`transam_assetible_id` = `transit_assets`.`id` AND `transam_assets`.`transam_assetible_type` = 'TransitAsset' INNER JOIN `infrastructures` ON `transit_assets`.`transit_assetible_id` = `infrastructures`.`id` AND `transit_assets`.`transit_assetible_type` = 'Infrastructure'
SQL

CREATE OR REPLACE VIEW parent_id_transam_assets_view AS
SELECT transam_assets.id AS id, parents.object_key AS parent_object_key
FROM transam_assets
INNER JOIN `transit_assets` ON `transam_assets`.`transam_assetible_id` = `transit_assets`.`id` AND `transam_assets`.`transam_assetible_type` = 'TransitAsset'
INNER JOIN transam_assets AS parents ON parents.id = transam_assets.parent_id
WHERE fta_asset_category_id != 4
UNION
SELECT transam_assets.id AS id, parents.object_key AS parent_object_key
FROM transam_assets
INNER JOIN `transit_assets` ON `transam_assets`.`transam_assetible_id` = `transit_assets`.`id` AND `transam_assets`.`transam_assetible_type` = 'TransitAsset'
INNER JOIN infrastructures_object_key_view AS parents ON parents.id = transam_assets.parent_id
WHERE fta_asset_category_id = 4

DROP VIEW if exists transit_components_description_view;
CREATE OR REPLACE VIEW transit_components_description_view AS
    select transam_assets.id as transam_asset_id, transam_assets.description as transit_component_description from transam_assets
    left join transit_assets on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'
    left join transit_components on transit_components.id = transit_assets.transit_assetible_id
    where transit_assets.transit_assetible_type = 'TransitComponent';

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
        AND asset_events.asset_event_type_id = 6;

CREATE OR REPLACE VIEW organizations_with_others_view AS
        SELECT id, short_name
        FROM organizations
        UNION SELECT -1 as id, 'Other' AS short_name
        UNION SELECT 0 as id, 'N/A' AS short_name