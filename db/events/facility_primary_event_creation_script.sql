-- IF running on a new instance that might have these views drop the views
DROP VIEW if EXISTS facility_primary_asset_table_views;
DROP VIEW IF EXISTS temp_facility_primary_asset_table_views;
DROP TABLE IF EXISTS temp_facility_primary_asset_table_views;

CREATE TABLE IF NOT EXISTS facility_primary_asset_table_views SELECT id FROM revenue_vehicles;

SET GLOBAL event_scheduler = ON;

delimiter |

CREATE EVENT IF NOT EXISTS facility_primary_asset_table_view_generator
ON SCHEDULE 
	EVERY 5 minute STARTS '2018-04-04-00:00:00'
COMMENT 'Regenerates the view table every 5 minutes'
DO
BEGIN
	CREATE TABLE IF NOT EXISTS temp_facility_primary_asset_table_views
		SELECT
        f.id,
        f.id AS 'facility_id',
          f.ada_accessible AS 'facility_ada_accessible',
          f.address1 AS 'facility_address1',
          f.address2 AS 'facility_address2',
          f.city AS 'facility_city',
          f.country AS 'facility_country',
          f.county AS 'facility_county',
          f.created_at AS 'facility_created_at',
          f.esl_category_id AS 'facility_esl_category_id***',
          f.facility_capacity_type_id AS 'facility_facility_capacity_type_id',
          f.facility_name AS 'facility_facility_name',
          f.facility_ownership_organization_id AS 'facility_facility_ownership_organization_id',
          f.facility_size AS 'facility_facility_size',
          f.facility_size_unit AS 'facility_facility_size_unit',
          f.fta_private_mode_type_id AS 'facility_fta_private_mode_type_id',
          f.land_ownership_organization_id AS 'facility_land_ownership_organization_id',
          f.leed_certification_type_id AS 'facility_leed_certification_type_id',
          f.lot_size AS 'facility_lot_size',
          f.lot_size_unit AS 'facility_lot_size_unit',
          f.ntd_id AS 'facility_ntd_id',
          f.num_elevators AS 'facility_num_elevators',
          f.num_escalators AS 'facility_num_escalators',
          f.num_floors AS 'facility_num_floors',
          f.num_parking_spaces_private AS 'facility_num_parking_spaces_private',
          f.num_parking_spaces_public AS 'facility_num_parking_spaces_public',
          f.num_structures AS 'facility_num_structures',
          f.other_facility_ownership_organization AS 'facility_other_facility_ownership_organization',
          f.other_land_ownership_organization AS 'facility_other_land_ownership_organization',
          f.section_of_larger_facility AS 'facility_section_of_larger_facility',
          f.state AS 'facility_state',
          f.updated_at AS 'facility_updated_at',
          f.zip AS 'facility_zip',

          esl_category.name AS 'facility_esl_category_name',

		  component.id AS 'component_id',
		  component.id AS 'facility_component_id',
          component.component_type_id AS 'facility_component_type_id',

          ct.name AS 'facility_component_type_name',

          cst.name AS 'facility_component_subtype_name',

          -- TODO Added to fix sandbox and QA should be removed longer term
          cst.name AS 'facility_subcomponent_type_name',

          transitAs.asset_id AS 'transit_asset_asset_id',
          transitAs.contract_num AS 'transit_asset_contract_num',
          transitAs.contract_type_id AS 'transit_asset_contract_type_id',
          transitAs.created_at AS 'transit_asset_created_at',
          transitAs.fta_asset_category_id AS 'transit_asset_fta_asset_category_id',
          transitAs.fta_asset_class_id AS 'fta_asset_class_id',
          transitAs.fta_asset_class_id AS 'transit_asset_fta_asset_class_id',
          transitAs.fta_type_id AS 'transit_asset_fta_type_id',
          transitAs.fta_type_type AS 'transit_asset_fta_type_type',
          transitAs.has_warranty AS 'transit_asset_has_warranty',
          transitAs.id AS 'transit_asset_id',
          transitAs.pcnt_capital_responsibility AS 'transit_asset_pcnt_capital_responsibility',
          transitAs.transit_assetible_id AS 'transit_asset_transit_assetible_id',
          transitAs.transit_assetible_type AS 'transit_asset_transit_assetible_type',
          transitAs.updated_at AS 'transit_asset_updated_at',
          transitAs.warranty_date AS 'transit_asset_warranty_date',
          transitAs.lienholder_id AS 'transit_asset_lienholder_id',
          transitAs.operator_id AS 'transit_asset_operator_id',
		  transitAs.other_lienholder AS 'transit_asset_other_lienholder',
		  transitAs.other_operator AS 'transit_asset_other_operator',
          transitAs.other_title_ownership_organization AS 'transit_asset_other_title_ownership_organization',
          transitAs.title_number AS 'transit_asset_title_number',
		  transitAs.title_ownership_organization_id AS 'transit_asset_title_ownership_organization_id',

          fta_asset_class.active AS 'transit_asset_fta_asset_class_active',
          fta_asset_class.class_name AS 'transit_asset_fta_asset_class_class_name',
          fta_asset_class.display_icon_name AS 'transit_asset_fta_asset_class_display_icon_name',
          fta_asset_class.fta_asset_category_id AS 'transit_asset_fta_asset_class_fta_asset_category_id',
          fta_asset_class.name AS 'transit_asset_fta_asset_class_name',

          fta_facility_type.active AS 'transit_asset_fta_type_active',
          fta_facility_type.description AS 'transit_asset_fta_type_description',
          fta_facility_type.fta_asset_class_id AS 'transit_asset_fta_type_fta_asset_class_id',
          fta_facility_type.name AS 'transit_asset_fta_type_name',
          fta_facility_type.class_name AS 'transit_asset_fta_type_class_name',

          transamAs.asset_subtype_id AS 'transam_asset_asset_subtype_id',
          transamAs.asset_tag AS 'asset_tag',
          transamAs.asset_tag AS 'transam_asset_asset_tag',
          transamAs.book_value AS 'transam_asset_book_value',
          transamAs.created_at AS 'transam_asset_created_at',
          transamAs.current_depreciation_date AS 'transam_asset_current_depreciation_date',
          transamAs.depreciable AS 'transam_asset_depreciable',
        transamAs.depreciation_purchase_cost AS 'transam_asset_depreciation_purchase_cost',
          transamAs.depreciation_start_date AS 'transam_asset_depreciation_start_date',
          transamAs.depreciation_useful_life AS 'transam_asset_depreciation_useful_life',
          transamAs.description AS 'transam_asset_description',
          transamAs.disposition_date AS 'transam_asset_disposition_date',
          transamAs.early_replacement_reason AS 'transam_asset_early_replacement_reason',
          transamAs.external_id AS 'transam_asset_external_id',
          transamAs.geometry AS 'transam_asset_geometry',
          transamAs.id AS 'transam_asset_id',
          transamAs.in_backlog AS 'transam_asset_in_backlog',
          transamAs.in_service_date AS 'transam_asset_in_service_date',
          transamAs.location_id AS 'transam_asset_location_id',
          transamAs.location_reference AS 'transam_asset_location_reference',
          transamAs.location_reference_type_id AS 'transam_asset_location_reference_type_id',
          transamAs.manufacturer_id AS 'transam_asset_manufacturer_id',
          transamAs.manufacturer_model_id AS 'transam_asset_manufacturer_model_id',
          transamAs.manufacture_year AS 'transam_asset_manufacture_year',
          transamAs.object_key AS 'object_key',
          transamAs.object_key AS 'transam_asset_object_key',
        transamAs.organization_id AS 'organization_id',
          transamAs.organization_id AS 'transam_asset_organization_id',
          transamAs.other_manufacturer AS 'transam_asset_other_manufacturer',
          transamAs.other_manufacturer_model AS 'transam_asset_other_manufacturer_model',
          transamAs.other_vendor AS 'transam_asset_other_vendor',
          transamAs.parent_id AS 'transam_asset_parent_id',
          transamAs.policy_replacement_year AS 'transam_asset_policy_replacement_year',
          transamAs.purchase_cost AS 'transam_asset_purchase_cost',
          transamAs.purchase_date AS 'transam_asset_purchase_date',
          transamAs.purchased_new AS 'transam_asset_purchased_new',
          transamAs.quantity AS 'transam_asset_quantity',
          transamAs.quantity_unit AS 'transam_asset_quantity_unit',
          transamAs.salvage_value AS 'transam_asset_salvage_value',
          transamAs.scheduled_disposition_year AS 'transam_asset_scheduled_disposition_year',
          transamAs.scheduled_rehabilitation_year AS 'transam_asset_scheduled_rehabilitation_year',
          transamAs.scheduled_replacement_cost AS 'transam_asset_scheduled_replacement_cost',
          transamAs.scheduled_replacement_year AS 'transam_asset_scheduled_replacement_year',
          transamAs.transam_assetible_id AS 'transam_asset_transam_assetible_id',
          transamAs.transam_assetible_type AS 'transam_asset_transam_assetible_type',
          transamAs.updated_at AS 'transam_asset_updated_at',
          transamAs.upload_id AS 'transam_asset_upload_id',
          transamAs.vendor_id AS 'transam_asset_vendor_id',

        ast.active AS 'transam_asset_asset_subtype_active',
          ast.asset_type_id AS 'transam_asset_asset_subtype_asset_type_id',
          ast.description AS 'transam_asset_asset_subtype_description',
          ast.image AS 'transam_asset_asset_subtype_image',
          ast.name AS 'transam_asset_asset_subtype_name',

          location.asset_tag AS 'transam_asset_location_name',
          location.asset_tag AS 'transam_asset_location_asset_tag',
          location.description AS 'transam_asset_location_description',

        manufacturer.active AS 'transam_asset_manufacturer_active',
          manufacturer.code AS 'transam_asset_manufacturer_code',
          manufacturer.filter AS 'transam_asset_manufacturer_filter',
          manufacturer.name AS 'transam_asset_manufacturer_name',

          model.active AS 'transam_asset_manufacturer_model_active',
          model.created_at AS 'transam_asset_manufacturer_model_created_at',
          model.description AS 'transam_asset_manufacturer_model_description',
          model.name AS 'transam_asset_manufacturer_model_name',
          model.organization_id AS 'transam_asset_manufacturer_model_organization_id',
          model.updated_at AS 'transam_asset_manufacturer_model_updated_at',

          operator.short_name AS 'transam_asset_operator_short_name',

          org.short_name AS 'transam_asset_organization_short_name',
          org.grantor_id AS 'transam_asset_organization_grantor_id',
          org.organization_type_id AS 'transam_asset_organization_type_id',


          policy.active AS 'transam_asset_org_policy_active',
          policy.condition_estimation_type_id AS 'transam_asset_org_policy_condition_estimation_type_id',
          policy.condition_threshold AS 'transam_asset_org_policy_condition_threshold',
          policy.created_at AS 'transam_asset_org_policy_created_at',
          policy.depreciation_calculation_type_id AS 'transam_asset_org_policy_depreciation_calculation_type_id',
          policy.depreciation_interval_type_id AS 'transam_asset_org_policy_depreciation_interval_type_id',
          policy.description AS 'transam_asset_org_policy_description',
          policy.id AS 'transam_asset_org_policy_id',
          policy.object_key AS 'transam_asset_org_policy_object_key',
          policy.organization_id AS 'transam_asset_org_policy_organization_id',
          policy.parent_id AS 'transam_asset_org_policy_parent_id',
          policy.updated_at AS 'transam_asset_org_policy_updated_at',

        serial_number.identification AS 'transam_asset_serial_number_identification',

          mrAev.asset_event_id AS 'most_recent_asset_event_id',
          rae_condition.asset_event_id AS 'condition_event_id',
          rae_service_status.asset_event_id AS 'service_status_event_id',
          rae_rebuild.asset_event_id AS 'rebuild_event_id',
          rae_mileage.asset_event_id AS 'mileage_event_id',
          rae_early_replacement_status.asset_event_id AS 'early_replacement_status_event_id',

          fleets.agency_fleet_id AS 'fleet_agency_fleet_id',
          fleets.asset_fleet_type_id AS 'fleet_asset_fleet_type_id',
          fleets.created_at AS 'fleet_created_at',
          fleets.created_by_user_id AS 'fleet_created_by_user_id',
          fleets.fleet_name AS 'fleet_fleet_name',
          fleets.id AS 'fleet_id',
          fleets.notes AS 'fleet_notes',
          fleets.ntd_id AS 'fleet_ntd_id',
          fleets.object_key AS 'fleet_object_key',
          fleets.organization_id AS 'fleet_organization_id',
          fleets.updated_at AS 'fleet_updated_at',

          most_recent_asset_event.asset_event_type_id AS 'most_recent_event_asset_event_type_id',
          most_recent_asset_event.updated_at AS 'most_recent_asset_event_updated_at',
          asset_event_type.name AS 'most_recent_asset_event_asset_event_type_name',

          most_recent_condition_event.condition_type_id AS 'most_recent_condition_event_condition_type_id',
          most_recent_condition_event.assessed_rating AS 'most_recent_condition_event_assessed_rating',
          most_recent_condition_event.updated_at AS 'most_recent_condition_event_updated_at',
          condition_type.name AS 'most_recent_condition_event_condition_type_name',

          -- most_recent_maintenance_event.asset_id,

          most_recent_service_status_event.service_status_type_id AS 'most_recent_service_status_event_service_status_type_id',
          service_status_type.name AS 'most_recent_service_status_event_service_status_type_name',

          most_recent_rebuild_event.extended_useful_life_months AS 'most_recent_rebuild_event_extended_useful_life_months',
          most_recent_rebuild_event.comments AS 'most_recent_rebuild_event_comments',
          most_recent_rebuild_event.updated_at AS 'most_recent_rebuild_event_updated_at',

          most_recent_mileage_event.current_mileage AS 'most_recent_mileage_event_current_mileage',
          most_recent_mileage_event.updated_at AS 'most_recent_mileage_event_updated_at',

		      NULL AS 'most_recent_early_replacement_event_replacement_status_type_id',
          NULL AS 'most_recent_early_replacement_event_replacement_status_type_name',
		      NOW() AS 'table_created_at'

      FROM transam_assets AS transamAs
      LEFT JOIN transit_assets AS transitAs ON transitAs.id = transamAs.transam_assetible_id

      LEFT JOIN transit_assets AS parentAs ON parentAs.id = transamAs.parent_id
      LEFT JOIN facilities AS f ON (transamAs.parent_id > 0 AND f.id = parentAs.transit_assetible_id) OR (transamAs.parent_id IS NULL AND f.id = transitAs.transit_assetible_id)
				AND transitAs.transit_assetible_type = 'Facility'

	    LEFT JOIN transit_components AS component ON component.id = transitAs.transit_assetible_id
		    AND transitAs.transit_assetible_type = 'TransitComponent'

      LEFT JOIN esl_categories AS esl_category ON esl_category.id = f.esl_category_id

      LEFT JOIN assets_asset_fleets AS aafleet ON aafleet.transam_asset_id = transamAs.id
      LEFT JOIN asset_fleets AS fleets ON fleets.id = aafleet.asset_fleet_id

      LEFT JOIN fta_asset_classes AS fta_asset_class ON fta_asset_class.id = transitAs.fta_asset_class_id
      LEFT JOIN fta_facility_types AS fta_facility_type ON fta_facility_type.id = transitAs.fta_type_id
      LEFT JOIN asset_subtypes AS ast ON ast.id = transamAs.asset_subtype_id

      LEFT JOIN transam_assets AS location ON location.id = transamAs.location_id
      LEFT JOIN manufacturers AS manufacturer ON manufacturer.id = transamAs.manufacturer_id
      LEFT JOIN manufacturer_models AS model ON model.id = transamAs.manufacturer_model_id
      LEFT JOIN organizations AS operator ON operator.id = transitAs.operator_id
      LEFT JOIN organizations AS org ON org.id = transamAs.organization_id
      LEFT JOIN organization_types AS org_type ON org_type.id = org.organization_type_id
      -- I am not thrilled about adding this business logic here but it was the only way to ensure we got the right policy.
      LEFT JOIN policies AS policy ON policy.id = (
          SELECT policies.id
              FROM policies
              WHERE IF(org_type.class_name='Planning Partner', org.grantor_id, org.id) = policies.organization_id
              LIMIT 1)
      LEFT JOIN serial_numbers AS serial_number ON serial_number.id = (
          SELECT id
              FROM serial_numbers
              WHERE identifiable_type = 'TransamAsset'
            AND identifiable_id = transamAs.id
              LIMIT 1)


	    LEFT JOIN all_assets_most_recent_asset_event_view AS mrAev ON mrAev.base_transam_asset_id = transamAs.id
      LEFT JOIN all_assets_recent_asset_events_for_type_view AS rae_condition ON rae_condition.base_transam_asset_id = transamAs.id
        AND rae_condition.asset_event_type_id = (SELECT id FROM asset_event_types WHERE NAME IN ('Condition') )
      -- LEFT JOIN recent_asset_events_for_type_view AS rae_maintenance ON rae_maintenance.transam_asset_id = transamAs.id
      -- 	AND rae_maintenance.asset_event_type_id =  SELECT id FROM asset_event_types WHERE NAME IN ('Maintenance provider type')
      LEFT JOIN all_assets_recent_asset_events_for_type_view AS rae_service_status ON rae_service_status.base_transam_asset_id = transamAs.id
        AND rae_service_status.asset_event_type_id = ( SELECT id FROM asset_event_types WHERE NAME IN ('Service status') )
      LEFT JOIN all_assets_recent_asset_events_for_type_view AS rae_rebuild ON rae_rebuild.base_transam_asset_id = transamAs.id
        AND rae_rebuild.asset_event_type_id = ( SELECT id FROM asset_event_types WHERE NAME IN ('Rebuild/rehabilitation') )
      LEFT JOIN all_assets_recent_asset_events_for_type_view AS rae_mileage ON rae_mileage.base_transam_asset_id = transamAs.id
        AND rae_mileage.asset_event_type_id = ( SELECT id FROM asset_event_types WHERE NAME IN ('Mileage') )
      LEFT JOIN all_assets_recent_asset_events_for_type_view AS rae_early_replacement_status ON rae_early_replacement_status.base_transam_asset_id = transamAs.id
        AND rae_early_replacement_status.asset_event_type_id = ( SELECT id FROM asset_event_types WHERE NAME IN ('Replacement status') )

      LEFT JOIN asset_events AS most_recent_asset_event ON most_recent_asset_event.id = mrAev.asset_event_id
      LEFT JOIN asset_events AS most_recent_condition_event ON most_recent_condition_event.id = rae_condition.asset_event_id
      LEFT JOIN asset_events AS most_recent_service_status_event ON most_recent_service_status_event.id = rae_service_status.asset_event_id
      LEFT JOIN asset_events AS most_recent_rebuild_event ON most_recent_rebuild_event.id = rae_rebuild.asset_event_id
      LEFT JOIN asset_events AS most_recent_mileage_event ON most_recent_mileage_event.id = rae_mileage.asset_event_id

      LEFT JOIN asset_event_types AS asset_event_type ON asset_event_type.id = most_recent_asset_event.asset_event_type_id
      LEFT JOIN condition_types AS condition_type ON condition_type.id = most_recent_condition_event.condition_type_id
      LEFT JOIN service_status_types AS service_status_type ON service_status_type.id = most_recent_service_status_event.service_status_type_id

      LEFT JOIN assets_fta_mode_types AS afmt ON afmt.transam_asset_id = f.id AND afmt.is_primary = 1 AND afmt.transam_asset_type = 'Facility'
      LEFT JOIN fta_mode_types AS fmt ON fmt.id = afmt.fta_mode_type_id

      LEFT JOIN component_types AS ct ON ct.id = component.component_type_id
      LEFT JOIN component_subtypes As cst on cst.id = component.component_subtype_id
      WHERE transamAs.transam_assetible_type = 'TransitAsset' AND (f.id >0 OR component.id > 0);
          
	  RENAME TABLE facility_primary_asset_table_views TO temp_delete_facility_primary_asset_table_views,
	temp_facility_primary_asset_table_views TO facility_primary_asset_table_views;
	
	  DROP TABLE temp_delete_facility_primary_asset_table_views;

END |

delimiter ;

SHOW EVENTS;    
