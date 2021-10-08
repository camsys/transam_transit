# desc "Explaining what the task does"
# task :transam_transit do
#   # Task goes here
# end
namespace :transam_transit_data do

  task add_early_disposition_requests_bulk_update: :environment do
    unless FileContentType.find_by(builder_name: "TransitEarlyDispositionRequestUpdatesTemplateBuilder").present?
      FileContentType.create!({:active => 1, :name => 'Early Disposition Requests', :class_name => 'EarlyDispositionRequestUpdatesFileHandler', :builder_name => "TransitEarlyDispositionRequestUpdatesTemplateBuilder", :description => 'Worksheet requests early disposition for existing inventory.'})
    end
  end

  desc 'add roles list for org types'
  task add_roles_organization_types: :environment do
    OrganizationType.find_by(class_name: 'Grantor').update!(roles: 'guest,manager')
    OrganizationType.find_by(class_name: 'TransitOperator').update!(roles: 'guest,user,transit_manager')
    OrganizationType.find_by(class_name: 'PlanningPartner').update!(roles: 'guest')
  end

  desc 'add facility rollup asset type/subtype'
  task add_facility_asset_subtypes: :environment do
    parent_policy_id = Policy.where('parent_id IS NULL').pluck(:id).first

    new_types = [
        {name: 'Substructure', description: 'Substructure', class_name: 'Component', display_icon_name: 'fa fa-cogs', map_icon_name: 'blueIcon', active: true},
        {name: 'Shell', description: 'Shell', class_name: 'Component', display_icon_name: 'fa fa-cogs', map_icon_name: 'blueIcon', active: true},
        {name: 'Interior', description: 'Interiors', class_name: 'Component', display_icon_name: 'fa fa-cogs', map_icon_name: 'blueIcon', active: true},
        {name: 'Conveyance', description: 'Conveyance', class_name: 'Component', display_icon_name: 'fa fa-cogs', map_icon_name: 'blueIcon', active: true},
        {name: 'Plumbing', description: 'Plumbing', class_name: 'Component', display_icon_name: 'fa fa-cogs', map_icon_name: 'blueIcon', active: true},
        {name: 'HVAC', description: 'HVAC', class_name: 'Component', display_icon_name: 'fa fa-cogs', map_icon_name: 'blueIcon', active: true},
        {name: 'Fire Protection', description: 'Fire Protection', class_name: 'Component', display_icon_name: 'fa fa-cogs', map_icon_name: 'blueIcon', active: true},
        {name: 'Electrical', description: 'Electrical', class_name: 'Component', display_icon_name: 'fa fa-cogs', map_icon_name: 'blueIcon', active: true},
        {name: 'Site', description: 'Site', class_name: 'Component', display_icon_name: 'fa fa-cogs', map_icon_name: 'blueIcon', active: true}
    ].each do |type|
      if AssetType.find_by(name: type[:name]).nil?
        a = AssetType.create!(type)
        PolicyAssetTypeRule.create(policy_id: parent_policy_id, asset_type_id: a.id, service_life_calculation_type_id: ServiceLifeCalculationType.find_by(name: 'Condition Only').id, replacement_cost_calculation_type_id: CostCalculationType.find_by(name: 'Purchase Price + Interest').id, condition_rollup_calculation_type_id: 1, annual_inflation_rate: 1.1, pcnt_residual_value: 0, condition_rollup_weight: 0 )
      end
    end

    [
        {asset_type: 'Substructure', name: 'All Substructure', description: 'All Substructures', active: true},
        {asset_type: 'Substructure', name: 'Foundation', description: 'Foundations', active: true},
        {asset_type: 'Substructure', name: 'Basement', description: 'Basement', active: true},
        {asset_type: 'Substructure', name: 'Foundation - Wall', description: 'Foundation - Wall', active: true},
        {asset_type: 'Substructure', name: 'Foundation - Column', description: 'Foundation - Column', active: true},
        {asset_type: 'Substructure', name: 'Foundation - Piling', description: 'Foundation - Piling', active: true},
        {asset_type: 'Substructure', name: 'Basement - Materials', description: 'Basement - Materials', active: true},
        {asset_type: 'Substructure', name: 'Basement - Insulation', description: 'Basement - Insulation', active: true},
        {asset_type: 'Substructure', name: 'Basement - Slab', description: 'Basement - Slab', active: true},
        {asset_type: 'Substructure', name: 'Basement - Floor Underpinning', description: 'Basement - Floor Underpinning', active: true},

        {asset_type: 'Shell', name: 'All Shell Structure', description: 'All Structures', active: true},
        {asset_type: 'Shell', name: 'Superstructure', description: 'Superstructure', active: true},
        {asset_type: 'Shell', name: 'Roof', description: 'Roof', active: true},
        {asset_type: 'Shell', name: 'Exterior', description: 'Exterior', active: true},
        {asset_type: 'Shell', name: 'Shell Appurtenance', description: 'Shell Appurtenances', active: true},
        {asset_type: 'Shell', name: 'Superstructure - Column', description: 'Superstructure - Column', active: true},
        {asset_type: 'Shell', name: 'Superstructure - Pillar', description: 'Superstructure - Pillar', active: true},
        {asset_type: 'Shell', name: 'Superstructure - Wall', description: 'Superstructure - Wall', active: true},
        {asset_type: 'Shell', name: 'Roof - Surface', description: 'Roof - Surface', active: true},
        {asset_type: 'Shell', name: 'Roof - Gutters', description: 'Roof - Gutters', active: true},
        {asset_type: 'Shell', name: 'Roof - Eaves', description: 'Roof - Eaves', active: true},
        {asset_type: 'Shell', name: 'Roof - Skylight', description: 'Roof - Skylight', active: true},
        {asset_type: 'Shell', name: 'Roof - Chimney Surroundings', description: 'Roof - Chimney Surroundings', active: true},
        {asset_type: 'Shell', name: 'Exterior - Window', description: 'Exterior - Window', active: true},
        {asset_type: 'Shell', name: 'Exterior - Door', description: 'Exterior - Door', active: true},
        {asset_type: 'Shell', name: 'Exterior - Finishes', description: 'Exterior - Finishes', active: true},
        {asset_type: 'Shell', name: 'Shell Appurtenance - Balcony', description: 'Shell Appurtenance - Balcony', active: true},
        {asset_type: 'Shell', name: 'Shell Appurtenance - Fire Escape', description: 'Shell Appurtenance - Fire Escape', active: true},
        {asset_type: 'Shell', name: 'Shell Appurtenance - Gutter', description: 'Shell Appurtenance - Gutter', active: true},
        {asset_type: 'Shell', name: 'Shell Appurtenance - Downspout', description: 'Shell Appurtenance - Downspout', active: true},

        {asset_type: 'Interior', name: 'All Interior', description: 'All Interior', active: true},
        {asset_type: 'Interior', name: 'Partition', description: 'Partition', active: true},
        {asset_type: 'Interior', name: 'Stairs', description: 'Stairs', active: true},
        {asset_type: 'Interior', name: 'Finishes', description: 'Finishes', active: true},
        {asset_type: 'Interior', name: 'Partition - Wall', description: 'Partition - Wall', active: true},
        {asset_type: 'Interior', name: 'Partition - Door', description: 'Partition - Door', active: true},
        {asset_type: 'Interior', name: 'Partition - Fittings', description: 'Partition - Fittings', active: true},
        {asset_type: 'Interior', name: 'Stairs - Landing', description: 'Stairs - Landing', active: true},
        {asset_type: 'Interior', name: 'Finishes - Wall Materials', description: 'Finishes - Wall Materials', active: true},
        {asset_type: 'Interior', name: 'Finishes - Floor Materials', description: 'Finishes - Floor Materials', active: true},
        {asset_type: 'Interior', name: 'Finishes - Ceiling Materials', description: 'Finishes - Ceiling Materials', active: true},

        {asset_type: 'Conveyance', name: 'All Conveyance', description: 'All Conveyance', active: true},
        {asset_type: 'Conveyance', name: 'Elevator', description: 'Elevator', active: true},
        {asset_type: 'Conveyance', name: 'Escalator', description: 'Escalator', active: true},
        {asset_type: 'Conveyance', name: 'Lift', description: 'Lift', active: true},

        {asset_type: 'Plumbing', name: 'All Plumbing', description: 'All Plumbing', active: true},
        {asset_type: 'Plumbing', name: 'Fixture', description: 'Fixture', active: true},
        {asset_type: 'Plumbing', name: 'Water Distribution', description: 'Water Distribution', active: true},
        {asset_type: 'Plumbing', name: 'Sanitary Waste', description: 'Sanitary Waste', active: true},
        {asset_type: 'Plumbing', name: 'Rain Water Drainage', description: 'Rain Water Drainage', active: true},

        {asset_type: 'HVAC', name: 'HVAC System', description: 'HVAC System', active: true},
        {asset_type: 'HVAC', name: 'Energy Supply', description: 'Energy Supply', active: true},
        {asset_type: 'HVAC', name: 'Heat Generation and Distribution System', description: 'Heat Generation and Distribution System', active: true},
        {asset_type: 'HVAC', name: 'Cooling Generation and Distribution System', description: 'Cooling Generation and Distribution System', active: true},
        {asset_type: 'HVAC', name: 'Instrumentation', description: 'Testing, Balancing, Controls and Instrumentation', active: true},

        {asset_type: 'Fire Protection', name: 'All Fire Protection', description: 'All Fire Protection', active: true},
        {asset_type: 'Fire Protection', name: 'Sprinkler', description: 'Sprinkler', active: true},
        {asset_type: 'Fire Protection', name: 'Standpipes', description: 'Standpipes', active: true},
        {asset_type: 'Fire Protection', name: 'Hydrant', description: 'Hydrant', active: true},
        {asset_type: 'Fire Protection', name: 'Other Fire Protection', description: 'Other Fire Protection', active: true},

        {asset_type: 'Electrical', name: 'All Electrical', description: 'All Electrical', active: true},
        {asset_type: 'Electrical', name: 'Service & Distribution', description: 'Service & Distribution', active: true},
        {asset_type: 'Electrical', name: 'Lighting & Branch Wiring', description: 'Lighting & Branch Wiring', active: true},
        {asset_type: 'Electrical', name: 'Communications & Security', description: 'Communications & Security', active: true},
        {asset_type: 'Electrical', name: 'Other Electrical', description: 'Other Electrical', active: true},
        {asset_type: 'Electrical', name: 'Lighting & Branch Wiring - Interior', description: 'Lighting & Branch Wiring - Interior', active: true},
        {asset_type: 'Electrical', name: 'Lighting & Branch Wiring - Exterior', description: 'Lighting & Branch Wiring - Exterior', active: true},
        {asset_type: 'Electrical', name: 'Lighting Protection', description: 'Lighting Protection', active: true},
        {asset_type: 'Electrical', name: 'Generator', description: 'Generator', active: true},
        {asset_type: 'Electrical', name: 'Emergency Lighting', description: ' Emergency Lighting', active: true},

        {asset_type: 'Site', name: 'All Site', description: 'All Site', active: true},
        {asset_type: 'Site', name: 'Roadways/Driveways', description: 'Roadways/Driveways', active: true},
        {asset_type: 'Site', name: 'Parking', description: 'Parking', active: true},
        {asset_type: 'Site', name: 'Pedestrian Area', description: 'Pedestrian Area', active: true},
        {asset_type: 'Site', name: 'Site Development', description: 'Site Development', active: true},
        {asset_type: 'Site', name: 'Landscaping and Irrigation', description: 'Landscaping and Irrigation', active: true},
        {asset_type: 'Site', name: 'Utilities', description: 'Utilities', active: true},
        {asset_type: 'Site', name: 'Roadways/Driveways - Signage', description: 'Roadways/Driveways - Signage', active: true},
        {asset_type: 'Site', name: 'Roadways/Driveways - Markings', description: 'Roadways/Driveways - Markings', active: true},
        {asset_type: 'Site', name: 'Roadways/Driveways - Equipment', description: 'Roadways/Driveways - Equipment', active: true},
        {asset_type: 'Site', name: 'Parking - Signage', description: 'Parking - Signage', active: true},
        {asset_type: 'Site', name: 'Parking - Markings', description: 'Parking - Markings', active: true},
        {asset_type: 'Site', name: 'Parking - Equipment', description: 'Parking - Equipment', active: true},
        {asset_type: 'Site', name: 'Pedestrian Area - Signage', description: 'Pedestrian Area - Signage', active: true},
        {asset_type: 'Site', name: 'Pedestrian Area - Markings', description: 'Pedestrian Area - Markings', active: true},
        {asset_type: 'Site', name: 'Pedestrian Area - Equipment', description: 'Pedestrian Area - Equipment', active: true},
        {asset_type: 'Site', name: 'Site Development - Fence', description: 'Site Development - Fence', active: true},
        {asset_type: 'Site', name: 'Site Development - Wall', description: 'Site Development - Wall', active: true},

    ].each do |subtype|
      if AssetSubtype.find_by(name: subtype[:name]).nil?
        a = AssetSubtype.new (subtype.except(:asset_type))
        a.asset_type = AssetType.find_by(name: subtype[:asset_type])
        a.save!

        PolicyAssetSubtypeRule.create!(policy_id: parent_policy_id, asset_subtype_id: a.id, min_service_life_months: 120, min_used_purchase_service_life_months: 48, replace_with_new: true, replace_with_leased: false, purchase_replacement_code: 'XX.XX.XX', rehabilitation_code: 'XX.XX.XX')
      end
    end
  end

  desc "Sync mileage and TERM condition between RTA and TransAM for orgs with RTA API access"
  task sync_rta: :environment do
    logger = Logger.new(File.join(Rails.root, 'log', 'clockwork.log'))

    s = RtaApiService.new
    Organization.where.not(rta_client_id: nil, rta_client_secret: nil, rta_tenant_id: nil).each do |o|
      logger.info "Syncing RTA for #{o.short_name}"
      processed_count = 0
      syncing_errors = {}
      # facilities.each do |f|
      #   puts "Processing data for facility #{f["name"]}"

      # TODO: Implement work orders
      # TODO: VMRS codes seem to be set per org???
      # VMRS codes
      vmrs_codes = {
          inspection_oil: {
              pm_a_lof_wc_lift_frta: "066-001-000",
              pm_b_lof_wc_lift_frta: "066-010-000",
              pm_c_lof_wc_lift_frta: "066-020-000"
          },
          inspection_no_oil: {
              mass_state_insp_brta: "005-000-000",
              pm_safety_lrta: "066-001-000",
              pm_a_weekly_brta: "066-001-000",
              pm_a_no_oil_wc_lift_frta: "066-002-000",
              pm_mass_lrta: "066-006-000",
              pm_f_mass_lrta: "066-006-010",
              pm_h_spring_brta: "066-008-000",
              pm_j_fall_brta: "066-009-000",
              pm_b_no_oil_wc_lift_frta: "066-011-000",
              pm_c_no_oil_wc_lift_frta: "066-021-000",
              pm_wc_lift_ramp_frta: "066-050-000",
          },
          lof_only: {
              pm_oil_filter_only_frta: "066-055-000",
              lof_lrta: "066-002-000",
              pm_rr_rearend_gear_oil_50k_brta: "066-010-000"
          },
          general_pm: {
              preventative_maintenance: "066-000-000",
              pm_b_brta: "066-002-000",
              pm_c_brta: "066-003-000",
              pm_c_lrta: "066-003-000",
              pm_d_brta: "066-004-000",
              pm_tune_up_lrta: "066-004-000",
              pm_d_tune_up_lrta: "066-004-010",
              pm_e_trany_fluid_change_brta: "066-005-000",
              pm_e_trans_lrta: "066-005-010",
              pm_f_brta: "066-006-000",
              pm_g_camera_pm_brta: "066-007-000",
              pm_coolant_lrta: "066-007-000",
              pm_g_coolant_lrta: "066-007-010",
              pm_repack_bearangs_lrta: "066-009-000",
              pm_j_repack_bearangs_lrta: "066-009-010",
              pm_a_maint_ck_gatra: "080-100-000",
              pm_b_spring_fall_gatra: "080-200-000",
              pm_d_winterization_gatra: "080-301-000"
          }
      }

      RTA_VMRS = {
          pm_a_safety_inspection: "066-001-000",
          pm_b_lube_oil_filter_change: "066-002-000",
          pm_c_tran_diff_oil_filter_change: "066-003-000",
          pm_d: "066-004-000",
          pm_e: "066-005-000",
          pm_f: "066-006-000",
          pm_g: "066-007-000",
          pm_h: "066-008-000",
          pm_j_annual_inspection: "066-009-000"
      }

      facilities = s.get_facilities(o.rta_tenant_id, o.rta_client_id, o.rta_client_secret)[:response]["data"]["getFacilities"]["facilities"]
      facilities.each do |f|
        logger.info "Processing work orders for facility #{f["name"]}"
        work_orders = s.get_todays_work_orders(o.rta_tenant_id, f["id"], o.rta_client_id, o.rta_client_secret)[:response]["data"]["getWorkOrders"]["workOrders"]
        work_orders.each do |wo|
          service_vehicle = ServiceVehicle.find_by(serial_number: wo["vehicle"]["serialNumber"])
          if service_vehicle
            mileage = wo["meter"]
            wo["lines"].each do |l|
              code = l["vmrs"]["code"]
              if vmrs_codes[:inspection_oil].merge(vmrs_codes[:inspection_no_oil]).has_value?(code)
                begin
                  event_date = Date.parse(wo["finishedAt"])
                  MaintenanceUpdateEvent.create(transam_asset: service_vehicle.transit_asset,
                                                maintenance_type: MaintenanceType.find_by(name: "Standard PM Inspection"),
                                                current_mileage: mileage,
                                                event_date: event_date,
                                                comments: l["jobDescription"] + " -Synced from RTA-")
                rescue ArgumentError || TypeError
                  logger.error "Invalid date for inspection on vehicle #{service_vehicle.serial_number}"
                end
              end
              if vmrs_codes[:inspection_oil].merge(vmrs_codes[:lof_only]).has_value?(code)
                begin
                  event_date = Date.parse(wo["finishedAt"])
                  MaintenanceUpdateEvent.create(transam_asset: service_vehicle.transit_asset,
                                                maintenance_type: MaintenanceType.find_by(name: "Oil Change/Filter/Lube"),
                                                current_mileage: mileage,
                                                event_date: event_date,
                                                comments: l["jobDescription"] + " -Synced from RTA-")
                rescue ArgumentError || TypeError
                  logger.error "Invalid date for oil/lube/filter change on vehicle #{service_vehicle.serial_number}"
                end
              end
            end
          else
            logger.warn "Vehicle #{wo["vehicle"]["serialNumber"]} not found in TransAM system"
          end
        end
      end

      logger.info "Processing work orders for facility #{f["name"]}"
      vehicle_states = s.get_vehicle_states_all_facilities(o.rta_tenant_id, o.rta_client_id, o.rta_client_secret)[:response]["data"]["getVehiclesInAllFacilities"]["vehicles"]
      vehicle_states.each do |v|
        service_vehicle = ServiceVehicle.find_by(serial_number: v["serialNumber"])
        if service_vehicle
          if mileage_last_updated = v["meters"]["meter"]["lastPostedDate"]
            begin
              if (Date.parse(mileage_last_updated) > service_vehicle.mileage_updates.last&.event_date) && (v["meters"]["meter"]["reading"] != service_vehicle.reported_mileage)
                old_mileage = service_vehicle.reported_mileage
                new_mileage = v["meters"]["meter"]["reading"]
                if old_mileage > new_mileage
                  error_message = "<p>Cannot update mileage for vehicle #{v["serialNumber"]} from #{old_mileage} to #{new_mileage}.</p>"
                  if syncing_errors[v["serialNumber"]]
                    syncing_errors[v["serialNumber"]].push(error_message)
                  else
                    syncing_errors[v["serialNumber"]] = [error_message]
                  end
                elsif Date.parse(mileage_last_updated) < service_vehicle.disposition_updates.last&.event_date
                  error_message = "<p>Cannot update mileage for vehicle #{v["serialNumber"]}: Vehicle was disposed on #{service_vehicle.disposition_updates.last&.event_date}, but mileage update occurred on #{Date.parse(mileage_last_updated)}.</p>"
                  if syncing_errors["dispositionConflicts"]
                    syncing_errors["dispositionConflicts"].push(error_message)
                  else
                    syncing_errors["dispositionConflicts"] = [error_message]
                  end
                else
                  MileageUpdateEvent.create(transam_asset: service_vehicle,
                                            current_mileage: new_mileage,
                                            event_date: Date.parse(mileage_last_updated) || Date.today,
                                            comments: "Synced from RTA")
                  logger.info "Updated vehicle #{service_vehicle.serial_number} mileage from #{old_mileage} to #{new_mileage}"
                end
              end
            rescue ArgumentError
              logger.error "Invalid date for mileage update on vehicle #{service_vehicle.serial_number}"
            end
          end
          if rta_rating = v["condition"]["value"]
            converted_rating =
              case rta_rating
              when 1
                5.to_d
              when 2
                4.to_d
              when 3
                3.to_d
              when 4
                2.to_d
              when 5
                1.to_d
              end

            if condition_last_updated = v["conditionLastUpdated"]
              begin
                if (Date.parse(condition_last_updated) > service_vehicle.condition_updates.last&.event_date) && (converted_rating != service_vehicle.reported_condition_rating)
                  old_rating = service_vehicle.reported_condition_rating
                  ConditionUpdateEvent.create(transam_asset: service_vehicle.transam_asset,
                                              assessed_rating: converted_rating,
                                              condition_type: ConditionType.from_rating(converted_rating),
                                              event_date: condition_last_updated || Date.today,
                                              comments: "Synced from RTA")
                  logger.info "Updated vehicle #{service_vehicle.serial_number} condition from #{old_rating} to #{converted_rating}"
                end
              rescue ArgumentError
                logger.error "Invalid date for condition update on vehicle #{service_vehicle.serial_number}"
              end
            end
          end
        else
          logger.warn "Vehicle #{v["serialNumber"]} not found in TransAM system"
        end
        processed_count += 1
      end
      if syncing_errors.length > 0
        email_body = "<p>Data sync with RTA for #{o.short_name} has encountered the following errors:</p>"
        syncing_errors.except("dispositionConflicts").each do |k,v|
          email_body += v.join
        end
        if syncing_errors["dispositionConflicts"]
          email_body += "<p></p><p>The following vehicles were unable to be updated due to conflicts with vehicle disposition in TransAM:</p>"
          syncing_errors["dispositionConflicts"].each do |v|
            email_body += v
          end
        end
        Message.create(
            organization: User.find_by(first_name: 'system', last_name: 'user').organization,
            user: User.find_by(first_name: 'system', last_name: 'user'),
            to_user: User.find_by(first_name: 'system', last_name: 'user'),
            priority_type: PriorityType.find_by(name: "Normal"),
            subject: "RTA Syncing Error",
            body: email_body
        )
        logger.warn email_body
      end
      logger.info "Processed #{processed_count} records"
    end
  end
end