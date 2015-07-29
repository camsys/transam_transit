# Inventory searcher.
# Designed to be populated from a search form using a new/create controller model.
#
class AssetSearcher < BaseSearcher

  # Include the numeric sanitizers mixin
  include TransamNumericSanitizers

  # From the application config
  ASSET_BASE_CLASS_NAME     = SystemConfig.instance.asset_base_class_name

  # add any search params to this list.  Grouped based on their logical queries
  attr_accessor :organization_id,
                :organization_ids,
                :district_id,
                :asset_type_id,
                :asset_subtype_id,
                :manufacturer_id,
                :parent_id,
                :disposition_date,
                :keyword,
                :estimated_condition_type_id,
                :reported_condition_type_id,
                :vendor_id,
                :service_status_type_id,
                :manufacturer_model,
                :equipment_description,
                :fta_mode_type_id,
                :fta_bus_mode_type_id,
                :fta_vehicle_type_id,
                :fta_ownership_type_id,
                :fta_service_type_id,
                :fuel_type_id,
                :vehicle_storage_method_type_id,
                :vehicle_usage_code_id,
                :vehicle_feature_id,
                :fta_building_ownership_type_id,
                :fta_land_ownership_type_id,
                :facility_feature_id,
                :facility_capacity_type_id,
                :leed_certification_type_id,
                :fta_funding_type_id,
                :federal_funding_source_id,
                :non_federal_funding_source_id,
                :asset_scope,
                # Comparator-based (<=>)
                :manufacture_year,
                :manufacture_year_comparator,
                :purchase_cost,
                :purchase_cost_comparator,
                :replacement_year,
                :replacement_year_comparator,
                :scheduled_replacement_year,
                :scheduled_replacement_year_comparator,
                :policy_replacement_year,
                :policy_replacement_year_comparator,
                :purchase_date,
                :purchase_date_comparator,
                :manufacture_date,
                :manufacture_date_comparator,
                :in_service_date,
                :in_service_date_comparator,
                :equipment_quantity,
                :equipment_quantity_comparator,
                :reported_mileage,
                :reported_mileage_comparator,
                :current_mileage,
                :current_mileage_comparator,
                :seating_capacity,
                :seating_capacity_comparator,
                :standing_capacity,
                :standing_capacity_comparator,
                :wheelchair_capacity,
                :wheelchair_capacity_comparator,
                :vehicle_length,
                :vehicle_length_comparator,
                :gross_vehicle_weight,
                :gross_vehicle_weight_comparator,
                :rebuild_year,
                :rebuild_year_comparator,
                :lot_size,
                :lot_size_comparator,
                :facility_size,
                :facility_size_comparator,
                :num_floors,
                :num_floors_comparator,
                :num_structures,
                :num_structures_comparator,
                :num_elevators,
                :num_elevators_comparator,
                :num_escalators,
                :num_escalators_comparator,
                :pcnt_operational,
                :pcnt_operational_comparator,
                :num_parking_spaces_private,
                :num_parking_spaces_private_comparator,
                :num_parking_spaces_public,
                :num_parking_spaces_public_comparator,
                # Checkboxes
                :in_backlog,
                :purchased_new,
                :fta_emergency_contingency_fleet,
                :ada_accessible_vehicle,
                :ada_accessible_facility,
                :five311_routes




  # Return the name of the form to display
  def form_view
    'asset_search_form'
  end
  # Return the name of the results table to display
  def results_view
    'asset_search_results_table'
  end

  def initialize(attributes = {})
    @klass = Object.const_get ASSET_BASE_CLASS_NAME
    super(attributes)
  end

  def to_s
    queries.to_sql
  end

  def cache_variable_name
    AssetsController::INDEX_KEY_LIST_VAR
  end

  private

  #---------------------------------------------------
  # Simple Equality Queries
  #---------------------------------------------------

  def estimated_condition_type_conditions
    clean_estimated_condition_type_id = remove_blanks(estimated_condition_type_id)
    @klass.where(estimated_condition_type_id: clean_estimated_condition_type_id) unless clean_estimated_condition_type_id.empty?
  end

  def reported_condition_type_conditions
    clean_reported_condition_type_id = remove_blanks(reported_condition_type_id)
    @klass.where(reported_condition_type_id: clean_reported_condition_type_id) unless clean_reported_condition_type_id.empty?
  end

  def manufacturer_conditions
    clean_manufacturer_id = remove_blanks(manufacturer_id)
    @klass.where(manufacturer_id: clean_manufacturer_id) unless clean_manufacturer_id.empty?
  end

  def district_type_conditions
    @klass.where(district_id: district_id) unless district_id.blank?
  end

  def asset_type_conditions
    clean_asset_type_id = remove_blanks(asset_type_id)
    @klass.where(asset_type_id: clean_asset_type_id) unless clean_asset_type_id.empty?
  end

  def asset_subtype_conditions
    clean_asset_subtype_id = remove_blanks(asset_subtype_id)
    @klass.where(asset_subtype_id: clean_asset_subtype_id) unless clean_asset_subtype_id.empty?
  end

  def location_id_conditions
    @klass.where(parent_id: parent_id) unless parent_id.blank?
  end

  def vendor_conditions
    clean_vendor_id = remove_blanks(vendor_id)
    @klass.where(vendor_id: clean_vendor_id) unless clean_vendor_id.empty?
  end

  def service_status_type_conditions
    clean_service_status_type_id = remove_blanks(service_status_type_id)
    @klass.where(service_status_type: clean_service_status_type_id) unless clean_service_status_type_id.empty?
  end

  #---------------------------------------------------
  # Simple Equality Searches Unique to Transit Queries
  #---------------------------------------------------

  def fta_funding_type_conditions
    clean_fta_funding_type_id = remove_blanks(fta_funding_type_id)
    @klass.where(fta_funding_type_id: clean_fta_funding_type_id) unless clean_fta_funding_type_id.empty?
  end

  def grant_conditions
    clean_funding_source_id = remove_blanks(federal_funding_source_id) + remove_blanks(non_federal_funding_source_id)

    unless clean_funding_source_id.empty?
      @klass.joins("INNER JOIN grant_purchases").joins("INNER JOIN grants").joins("INNER JOIN funding_sources").where("grant_purchases.grant_id = grants.id").where("grants.funding_source_id = funding_sources.id").where("funding_sources.id IN (?)", clean_funding_source_id)
    end
  end

  def asset_scope_conditions
    unless asset_scope.blank?
      case asset_scope
      when "Disposed"
        @klass.disposed
      when "Operational"
        @klass.operational
      when "In Service"
        @klass.in_service
      end
    end
  end

  #---------------------------------------------------
  # Comparator Queries
  #---------------------------------------------------
  def manufacture_year_conditions
    unless manufacture_year.blank?
      case manufacture_year_comparator
      when "-1" # Before Year X
        @klass.where("manufacture_year < ?", manufacture_year)
      when "0" # During Year X
        @klass.where("manufacture_year = ?", manufacture_year)
      when "1" # After Year X
        @klass.where("manufacture_year > ?", manufacture_year)
      end
    end
  end

  def scheduled_replacement_year_conditions
    unless scheduled_replacement_year.blank?
      case scheduled_replacement_year_comparator
      when "-1" # Before Year X
        @klass.where("scheduled_replacement_year < ?", scheduled_replacement_year)
      when "0" # During Year X
        @klass.where("scheduled_replacement_year = ?", scheduled_replacement_year)
      when "1" # After Year X
        @klass.where("scheduled_replacement_year > ?", scheduled_replacement_year)
      end
    end
  end

  def policy_replacement_year_conditions
    unless policy_replacement_year.blank?
      case policy_replacement_year_comparator
      when "-1" # Before Year X
        @klass.where("policy_replacement_year < ?", policy_replacement_year)
      when "0" # During Year X
        @klass.where("policy_replacement_year = ?", policy_replacement_year)
      when "1" # After Year X
        @klass.where("policy_replacement_year > ?", policy_replacement_year)
      end
    end
  end

  def purchase_cost_conditions
    unless purchase_cost.blank?
      purchase_cost_as_float = sanitize_to_float(purchase_cost)
      case purchase_cost_comparator
      when "-1" # Less than X miles
        @klass.where("purchase_cost < ?", purchase_cost)
      when "0" # Exactly X miles
        @klass.where("purchase_cost = ?", purchase_cost)
      when "1" # Greater than X miles
        @klass.where("purchase_cost > ?", purchase_cost)
      end
    end
  end

  def scheduled_replacement_year_conditions
    unless scheduled_replacement_year.blank?
      case scheduled_replacement_year_comparator
      when "-1" # Before Year X
        @klass.where("scheduled_replacement_year < ?", scheduled_replacement_year)
      when "0" # During Year X
        @klass.where("scheduled_replacement_year = ?", scheduled_replacement_year)
      when "1" # After Year X
        @klass.where("scheduled_replacement_year > ?", scheduled_replacement_year)
      end
    end
  end

  # Special handling because this is a Date column in the DB, not an integer
  def in_service_date_conditions
    unless in_service_date.blank?
      case in_service_date_comparator
      when "-1" # Before Year X
        @klass.where("in_service_date < ?", in_service_date)
      when "0" # During Year X
        @klass.where("in_service_date = ?", in_service_date)
      when "1" # After Year X
        @klass.where("in_service_date > ?", in_service_date)
      end
    end
  end

  #---------------------------------------------------
  # Checkbox Queries # Not checking a box is different than saying "restrict to things where this is false"
  #---------------------------------------------------

  def in_backlog_conditions
    @klass.where(in_backlog: true) unless in_backlog.to_i.eql? 0
  end

  def purchased_new_conditions
    @klass.where(purchased_new: true) unless purchased_new.to_i.eql? 0
  end

  #---------------------------------------------------
  # Custom Queries # When the logic does not fall into the above categories, place the method here
  #---------------------------------------------------

  def organization_conditions
    if organization_id.blank?
      ids = remove_blanks(organization_ids)
      if ids.empty?
        @klass.where(organization_id: user.organization_ids)
      else
        @klass.where(organization_id: ids)
      end
    else
      @klass.where(organization_id: organization_id)
    end
  end

  def keyword_conditions # TODO break apart by commas
    unless keyword.blank?
      searchable_columns = ["assets.manufacturer_model", "assets.description", "assets.asset_tag", "organizations.name", "organizations.short_name"] # add any freetext-searchable fields here
      keyword.strip!
      search_str = searchable_columns.map { |x| "#{x} like :keyword"}.to_sentence(:words_connector => " OR ", :last_word_connector => " OR ")
      @klass.joins(:organization).where(search_str, :keyword => "%#{keyword}%")
    end
  end

  def manufacturer_model_conditions
    unless manufacturer_model.blank?
      manufacturer_model.strip!
      wildcard_search = "%#{manufacturer_model}%"
      @klass.where("manufacturer_model LIKE ?", wildcard_search)
    end
  end

  # Equality check but requires type conversion and bounds checking
  def disposition_date_conditions
    unless disposition_date.blank?
      disposition_date_as_date = Date.new(disposition_date.to_i)
      @klass.where("disposition_date >= ? and disposition_date <= ?", disposition_date_as_date, disposition_date_as_date.end_of_year)
    end
  end

  # Special handling because this is a Date column in the DB, not an integer
  def purchase_date_conditions
    unless purchase_date.blank?
      case purchase_date_comparator
      when "-1" # Before Year X
        @klass.where("purchase_date < ?", purchase_date)
      when "0" # During Year X
        @klass.where("purchase_date = ?", purchase_date)
      when "1" # After Year X
        @klass.where("purchase_date > ?", purchase_date)
      end
    end
  end


  #---------------------------------------------------
  # Equipment Queries
  #---------------------------------------------------

  def equipment_description_conditions
    unless equipment_description.blank?
      equipment_description.strip!
      wildcard_search = "%#{equipment_description}%"
      @klass.where("assets.description LIKE ?", wildcard_search)
    end
  end

  def equipment_quantity_conditions
    unless equipment_quantity.blank?
      case equipment_quantity_comparator
      when "-1" # Less than X
        @klass.where("equipment_quantity < ?", equipment_quantity)
      when "0" # Equal to X
        @klass.where("equipment_quantity = ?", equipment_quantity)
      when "1" # Greater Than X
        @klass.where("equipment_quantity > ?", equipment_quantity)
      end
    end
  end
  #---------------------------------------------------
  # Vehicle Equality Queries
  #---------------------------------------------------
  def fta_mode_type_conditions
    clean_fta_mode_type_id = remove_blanks(fta_mode_type_id)
    @klass.joins("INNER JOIN assets_fta_mode_types").where("assets_fta_mode_types.asset_id = assets.id AND assets_fta_mode_types.fta_mode_type_id IN (?)",clean_fta_mode_type_id) unless clean_fta_mode_type_id.empty?
  end

  def vehicle_usage_code_conditions
    clean_vehicle_usage_code_id = remove_blanks(vehicle_usage_code_id)
    @klass.joins("INNER JOIN assets_usage_codes").where("assets_usage_codes.asset_id = assets.id AND assets_usage_codes.usage_code_id IN (?)",clean_vehicle_usage_code_id) unless clean_vehicle_usage_code_id.empty?
  end

  def vehicle_feature_code_conditions
    clean_vehicle_feature_id = remove_blanks(vehicle_feature_id)
    @klass.joins("INNER JOIN assets_vehicle_features").where("assets_vehicle_features.asset_id = assets.id AND assets_vehicle_features.vehicle_feature_id IN (?)",clean_vehicle_feature_id) unless clean_vehicle_feature_id.empty?
  end

  def fta_bus_mode_conditions
    clean_fta_bus_mode_type_id = remove_blanks(fta_bus_mode_type_id)
    @klass.where(fta_bus_mode_type_id: clean_fta_bus_mode_type_id) unless clean_fta_bus_mode_type_id.empty?
  end

  def fta_ownership_conditions
    clean_fta_ownership_type_id = remove_blanks(fta_ownership_type_id)
    @klass.where(fta_ownership_type_id: clean_fta_ownership_type_id) unless clean_fta_ownership_type_id.empty?
  end

  def fta_vehicle_type_conditions
    clean_fta_vehicle_type_id = remove_blanks(fta_vehicle_type_id)
    @klass.where(fta_vehicle_type_id: clean_fta_vehicle_type_id) unless clean_fta_vehicle_type_id.empty?
  end

  def fuel_type_conditions
    clean_fuel_type_id = remove_blanks(fuel_type_id)
    @klass.where(fuel_type_id: clean_fuel_type_id) unless clean_fuel_type_id.empty?
  end

  def vehicle_storage_method_conditions
    clean_vehicle_storage_method_type_id = remove_blanks(vehicle_storage_method_type_id)
    @klass.where(vehicle_storage_method_type_id: clean_vehicle_storage_method_type_id) unless clean_vehicle_storage_method_type_id.empty?
  end
  #---------------------------------------------------
  # Vehicle Comparator Queries
  #---------------------------------------------------
  def vehicle_length_conditions
    unless vehicle_length.blank?
      case vehicle_length_comparator
      when "-1" # Less than X
        @klass.where("vehicle_length < ?", vehicle_length)
      when "0" # Equal to X
        @klass.where("vehicle_length = ?", vehicle_length)
      when "1" # Greater Than X
        @klass.where("vehicle_length > ?", vehicle_length)
      end
    end
  end

  def gross_vehicle_weight_conditions
    unless gross_vehicle_weight.blank?
      case gross_vehicle_weight_comparator
      when "-1" # Less than X
        @klass.where("gross_vehicle_weight < ?", gross_vehicle_weight)
      when "0" # Equal to X
        @klass.where("gross_vehicle_weight = ?", gross_vehicle_weight)
      when "1" # Greater Than X
        @klass.where("gross_vehicle_weight > ?", gross_vehicle_weight)
      end
    end
  end

  def rebuild_year_conditions
    unless rebuild_year.blank?
      case rebuild_year_comparator
      when "-1" # Less than X
        @klass.where("rebuild_year < ?", rebuild_year)
      when "0" # Equal to X
        @klass.where("rebuild_year = ?", rebuild_year)
      when "1" # Greater Than X
        @klass.where("rebuild_year > ?", rebuild_year)
      end
    end
  end

  def seating_capacity_conditions
    unless seating_capacity.blank?
      case seating_capacity_comparator
      when "-1" # Less than X
        @klass.where("seating_capacity < ?", seating_capacity)
      when "0" # Equal to X
        @klass.where("seating_capacity = ?", seating_capacity)
      when "1" # Greater Than X
        @klass.where("seating_capacity > ?", seating_capacity)
      end
    end
  end

  def standing_capacity_conditions
    unless standing_capacity.blank?
      case standing_capacity_comparator
      when "-1" # Less than X
        @klass.where("standing_capacity < ?", standing_capacity)
      when "0" # Equal to X
        @klass.where("standing_capacity = ?", standing_capacity)
      when "1" # Greater Than X
        @klass.where("standing_capacity > ?", standing_capacity)
      end
    end
  end

  def wheelchair_capacity_conditions
    unless wheelchair_capacity.blank?
      case wheelchair_capacity_comparator
      when "-1" # Less than X
        @klass.where("wheelchair_capacity < ?", wheelchair_capacity)
      when "0" # Equal to X
        @klass.where("wheelchair_capacity = ?", wheelchair_capacity)
      when "1" # Greater Than X
        @klass.where("wheelchair_capacity > ?", wheelchair_capacity)
      end
    end
  end

  def current_mileage_conditions
    unless current_mileage.blank?
      case current_mileage_comparator
      when "-1" # Less than X
        @klass.joins(:asset_events).where("asset_events.current_mileage < ?", current_mileage)
      when "0" # Equal to X
        @klass.joins(:asset_events).where("asset_events.current_mileage = ?", current_mileage)
      when "1" # Greater Than X
        @klass.joins(:asset_events).where("asset_events.current_mileage > ?", current_mileage)
      end
    end
  end

  #---------------------------------------------------
  # Vehicle Checkbox Queries
  #---------------------------------------------------
  def fta_emergency_contingency_fleet_conditions
    @klass.where(fta_emergency_contingency_fleet: true) if fta_emergency_contingency_fleet.to_i == 1
  end

  def ada_accessible_conditions
    if (ada_accessible_vehicle.to_i == 1 || ada_accessible_facility.to_i == 1)
      clean_asset_type_id = remove_blanks(asset_type_id)

      if clean_asset_type_id == AssetType.find_by(:class_name => 'Vehicle').id
        query = 'ada_accessible_lift = 1'
      elsif AssetType.where("class_name LIKE '%Facility'").ids.include? clean_asset_type_id
        query = 'ada_accessible_ramp = 1'
      else
        query = 'ada_accessible_lift = 1 OR ada_accessible_ramp = 1'
      end

      @klass.where(query)
    end
  end

  def five311_route_conditions
    @klass.joins(:asset_events).where('asset_events.pcnt_5311_routes > 0') if five311_routes.to_i == 1
  end

  #---------------------------------------------------
  # Facility Equality Queries
  #---------------------------------------------------

  def facility_feature_conditions
    clean_facility_feature_id = remove_blanks(facility_feature_id)
    @klass.joins("INNER JOIN assets_facility_features").where("assets_facility_features.asset_id = assets.id AND assets_facility_features.facility_feature_id = ?",clean_facility_feature_id) unless clean_facility_feature_id.empty?
  end

  def facility_capacity_type_conditions
    clean_facility_capacity_type_id = remove_blanks(facility_capacity_type_id)
    @klass.where(facility_capacity_type_id: clean_facility_capacity_type_id) unless clean_facility_capacity_type_id.empty?
  end

  def fta_land_ownership_type_conditions
    clean_fta_land_ownership_type_id = remove_blanks(fta_land_ownership_type_id)
    @klass.where(land_ownership_type_id: clean_fta_land_ownership_type_id) unless clean_fta_land_ownership_type_id.empty?
  end

  def fta_building_ownership_type_conditions
    clean_fta_building_ownership_type_id = remove_blanks(fta_building_ownership_type_id)
    @klass.where(building_ownership_type_id: clean_fta_building_ownership_type_id) unless clean_fta_building_ownership_type_id.empty?
  end

  def leed_certification_type_conditions
    clean_leed_certification_type_id = remove_blanks(leed_certification_type_id)
    @klass.where(leed_certification_type_id: clean_leed_certification_type_id) unless clean_leed_certification_type_id.empty?
  end

  #---------------------------------------------------
  # Facility Comparator Queries
  #---------------------------------------------------


  def facility_size_conditions
    unless facility_size.blank?
      case facility_size_comparator
      when "-1" # Less than X
        @klass.where("facility_size < ?", facility_size)
      when "0" # Equal to X
        @klass.where("facility_size = ?", facility_size)
      when "1" # Greater Than X
        @klass.where("facility_size > ?", facility_size)
      end
    end
  end

  def lot_size_conditions
    unless lot_size.blank?
      case lot_size_comparator
      when "-1" # Less than X
        @klass.where("lot_size < ?", lot_size)
      when "0" # Equal to X
        @klass.where("lot_size = ?", lot_size)
      when "1" # Greater Than X
        @klass.where("lot_size > ?", lot_size)
      end
    end
  end

  def num_parking_spaces_private_conditions
    unless num_parking_spaces_private.blank?
      case num_parking_spaces_private_comparator
      when "-1" # Less than X
        @klass.where("num_parking_spaces_private < ?", num_parking_spaces_private)
      when "0" # Equal to X
        @klass.where("num_parking_spaces_private = ?", num_parking_spaces_private)
      when "1" # Greater Than X
        @klass.where("num_parking_spaces_private > ?", num_parking_spaces_private)
      end
    end
  end

  def num_parking_spaces_public_conditions
    unless num_parking_spaces_public.blank?
      case num_parking_spaces_public_comparator
      when "-1" # Less than X
        @klass.where("num_parking_spaces_public < ?", num_parking_spaces_public)
      when "0" # Equal to X
        @klass.where("num_parking_spaces_public = ?", num_parking_spaces_public)
      when "1" # Greater Than X
        @klass.where("num_parking_spaces_public > ?", num_parking_spaces_public)
      end
    end
  end

  def num_floors_conditions
    unless num_floors.blank?
      case num_floors_comparator
      when "-1" # Less than X
        @klass.where("num_floors < ?", num_floors)
      when "0" # Equal to X
        @klass.where("num_floors = ?", num_floors)
      when "1" # Greater Than X
        @klass.where("num_floors > ?", num_floors)
      end
    end
  end

  def pcnt_operational_conditions
    unless pcnt_operational.blank?
      case pcnt_operational_comparator
      when "-1" # Less than X
        @klass.where("pcnt_operational < ?", pcnt_operational)
      when "0" # Equal to X
        @klass.where("pcnt_operational = ?", pcnt_operational)
      when "1" # Greater Than X
        @klass.where("pcnt_operational > ?", pcnt_operational)
      end
    end
  end

  def num_structures_conditions
    unless num_structures.blank?
      case num_structures_comparator
      when "-1" # Less than X
        @klass.where("num_structures < ?", num_structures)
      when "0" # Equal to X
        @klass.where("num_structures = ?", num_structures)
      when "1" # Greater Than X
        @klass.where("num_structures > ?", num_structures)
      end
    end
  end

  def num_elevators_conditions
    unless num_elevators.blank?
      case num_elevators_comparator
      when "-1" # Less than X
        @klass.where("num_elevators < ?", num_elevators)
      when "0" # Equal to X
        @klass.where("num_elevators = ?", num_elevators)
      when "1" # Greater Than X
        @klass.where("num_elevators > ?", num_elevators)
      end
    end
  end

  def num_escalators_conditions
    unless num_escalators.blank?
      case num_escalators_comparator
      when "-1" # Less than X
        @klass.where("num_escalators < ?", num_escalators)
      when "0" # Equal to X
        @klass.where("num_escalators = ?", num_escalators)
      when "1" # Greater Than X
        @klass.where("num_escalators > ?", num_escalators)
      end
    end
  end

  # Removes empty spaces from multi-select forms

  def remove_blanks(input)
    output = (input.is_a?(Array) ? input : [input])
    output.select { |e| !e.blank? }
  end

end
