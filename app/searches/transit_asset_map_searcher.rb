# Inventory searcher.
# Designed to be populated from a search form using a new/create controller model.
#
class TransitAssetMapSearcher < BaseSearcher

  # Include the numeric sanitizers mixin
  include TransamNumericSanitizers

  def self.form_params
    [
        :district_id,
        :primary_fta_mode_type_id,
        :secondary_fta_mode_type_id,
        :fta_private_mode_type_id,
        :fta_bus_mode_type_id,
        :fta_vehicle_type_id,
        :fta_support_vehicle_type_id,
        :fta_ownership_type_id,
        :primary_fta_service_type_id,
        :secondary_fta_service_type_id,
        :fuel_type_id,
        :dual_fuel_type_id,
        :vehicle_storage_method_type_id,
        :vehicle_usage_code_id,
        :vehicle_feature_id,
        :fta_building_ownership_type_id,
        :fta_land_ownership_type_id,
        :facility_feature_id,
        :facility_capacity_type_id,
        :leed_certification_type_id,
        :fta_funding_type_id,
        # Comparator-based (<=>)
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

        :pcnt_capital_responsibility,
        :pcnt_capital_responsibility_comparator,
        # Checkboxes
        :fta_emergency_contingency_fleet,
        :ada_accessible_vehicle,
        :ada_accessible_facility,
        :five311_routes,
        :dedicated,
        :direct_capital_responsibility
    ]
  end

  private

  #---------------------------------------------------
  # Simple Equality Queries
  #---------------------------------------------------


  def district_type_conditions
    @klass.where(district_id: district_id) unless district_id.blank?
  end

  #---------------------------------------------------
  # Simple Equality Searches Unique to Transit Queries
  #---------------------------------------------------

  def fta_funding_type_conditions
    clean_fta_funding_type_id = remove_blanks(fta_funding_type_id)
    @klass.where(fta_funding_type_id: clean_fta_funding_type_id) unless clean_fta_funding_type_id.empty?
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

  def pcnt_capital_responsibility_conditions
    unless pcnt_capital_responsibility.blank?
      pcnt_capital_responsibility_as_int = sanitize_to_int(pcnt_capital_responsibility)
      case pcnt_capital_responsibility_comparator
        when "-1" # Less than X miles
          @klass.where("pcnt_capital_responsibility < ?", pcnt_capital_responsibility_as_int)
        when "0" # Exactly X miles
          @klass.where("pcnt_capital_responsibility = ?", pcnt_capital_responsibility_as_int)
        when "1" # Greater than X miles
          @klass.where("pcnt_capital_responsibility > ?", pcnt_capital_responsibility_as_int)
      end
    end
  end


  #---------------------------------------------------
  # Vehicle Equality Queries
  #---------------------------------------------------
  def primary_fta_mode_type_conditions
    clean_fta_mode_type_id = remove_blanks(primary_fta_mode_type_id)
    @klass.joins("INNER JOIN assets_fta_mode_types").where("assets_fta_mode_types.is_primary = 1 AND assets_fta_mode_types.asset_id = assets.id AND assets_fta_mode_types.fta_mode_type_id IN (?)",clean_fta_mode_type_id).distinct unless clean_fta_mode_type_id.empty?
  end

  def secondary_fta_mode_type_conditions
    clean_fta_mode_type_id = remove_blanks(secondary_fta_mode_type_id)
    @klass.joins("INNER JOIN assets_fta_mode_types").where("(assets_fta_mode_types.is_primary != 1 OR assets_fta_mode_types.is_primary IS NULL) AND assets_fta_mode_types.asset_id = assets.id AND assets_fta_mode_types.fta_mode_type_id IN (?)",clean_fta_mode_type_id).distinct unless clean_fta_mode_type_id.empty?
  end

  def fta_private_mode_type_conditions
    clean_mode_id = remove_blanks(fta_private_mode_type_id)
    @klass.where(fta_private_mode_type_id: clean_mode_id) unless clean_mode_id.empty?
  end

  def vehicle_usage_code_conditions
    clean_vehicle_usage_code_id = remove_blanks(vehicle_usage_code_id)
    @klass.joins("INNER JOIN assets_vehicle_usage_codes").where("assets_vehicle_usage_codes.asset_id = assets.id AND assets_vehicle_usage_codes.vehicle_usage_code_id IN (?)",clean_vehicle_usage_code_id).distinct unless clean_vehicle_usage_code_id.empty?
  end

  def vehicle_feature_code_conditions
    clean_vehicle_feature_id = remove_blanks(vehicle_feature_id)
    @klass.joins("INNER JOIN assets_vehicle_features").where("assets_vehicle_features.asset_id = assets.id AND assets_vehicle_features.vehicle_feature_id IN (?)",clean_vehicle_feature_id).distinct unless clean_vehicle_feature_id.empty?
  end

  def primary_fta_service_type_conditions
    clean_fta_service_type_id = remove_blanks(primary_fta_service_type_id)
    @klass.joins("INNER JOIN assets_fta_service_types").where("assets_fta_service_types.is_primary = 1 AND assets_fta_service_types.asset_id = assets.id AND assets_fta_service_types.fta_service_type_id IN (?)", clean_fta_service_type_id).distinct unless clean_fta_service_type_id.empty?
  end

  def secondary_fta_service_type_conditions
    clean_fta_service_type_id = remove_blanks(secondary_fta_service_type_id)
    @klass.joins("INNER JOIN assets_fta_service_types").where("(assets_fta_service_types.is_primary != 1 OR assets_fta_service_types.is_primary IS NULL) AND assets_fta_service_types.asset_id = assets.id AND assets_fta_service_types.fta_service_type_id IN (?)", clean_fta_service_type_id).distinct unless clean_fta_service_type_id.empty?
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

  def fta_support_vehicle_type_conditions
    clean_fta_vehicle_type_id = remove_blanks(fta_support_vehicle_type_id)
    @klass.where(fta_support_vehicle_type_id: clean_fta_vehicle_type_id) unless clean_fta_vehicle_type_id.empty?
  end


  def fuel_type_conditions
    clean_fuel_type_id = remove_blanks(fuel_type_id)
    @klass.where(fuel_type_id: clean_fuel_type_id) unless clean_fuel_type_id.empty?
  end

  def dual_fuel_type_conditions
    clean_dual_fuel_type_id = remove_blanks(dual_fuel_type_id)
    @klass.where(dual_fuel_type_id: clean_dual_fuel_type_id) unless clean_dual_fuel_type_id.empty?
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
        @klass.where("reported_mileage < ?", current_mileage)
      when "0" # Equal to X
        @klass.where("reported_mileage = ?", current_mileage)
      when "1" # Greater Than X
        @klass.where("reported_mileage > ?", current_mileage)
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

      if @klass.name == 'Vehicle'
        query = 'ada_accessible_lift = 1'
      elsif @klass.name.include? 'Facility'
        query = 'ada_accessible_ramp = 1'
      else
        query = 'ada_accessible_lift = 1 OR ada_accessible_ramp = 1'
      end

      @klass.where(query)
    end
  end

  def five311_route_conditions
    @klass.joins(:asset_events).where('asset_events.pcnt_5311_routes > 0').distinct if five311_routes.to_i == 1
  end

  def dedicated_conditions
    @klass.where('dedicated = 1') if dedicated.to_i == 1
  end

  #---------------------------------------------------
  # Facility Equality Queries
  #---------------------------------------------------

  def facility_feature_conditions
    clean_facility_feature_id = remove_blanks(facility_feature_id)
    @klass.joins("INNER JOIN assets_facility_features").where("assets_facility_features.asset_id = assets.id AND assets_facility_features.facility_feature_id = ?",clean_facility_feature_id).distinct unless clean_facility_feature_id.empty?
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
