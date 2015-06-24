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
                :class_name,
                :fta_mode_type_id,
                :fta_bus_mode_type_id,
                :fta_vehicle_type_id,
                :fta_ownership_type_id,
                :fta_service_type_id,
                :fuel_type_id,
                :vehicle_storage_method_type_id,
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
                # Checkboxes
                :in_backlog,
                :purchased_new,
                :fta_emergency_contingency_fleet,
                :ada_accessible,
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
      if organization_ids.empty?
        @klass.where(organization_id: get_id_list(user.organizations))
      else
        @klass.where(organization_id: organization_ids)
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


  #Equipment searches

  def equipment_description_conditions
    equipment_description.strip!
    wildcard_search = "%#{equipment_description}%"
    @klass.where("assets.description LIKE ?", wildcard_search) unless equipment_description.blank?
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

  #Vehicle Specific Queries

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

  def fta_emergency_contingency_fleet_conditions
    @klass.where(fta_emergency_contingency_fleet: true) if fta_emergency_contingency_fleet.to_i == 1
  end

  def ada_accessible_conditions
    @klass.where('ada_accessible_lift = 1 OR ada_accessible_ramp = 1') if ada_accessible.to_i == 1
  end

  def five311_route_conditions
    @klass.joins(:asset_events).where('asset_events.pcnt_5311_routes > 0') if five311_routes.to_i == 1
  end

  # Removes empty spaces from multi-select forms

  def remove_blanks(input)
    output = (input.is_a?(Array) ? input : [input])
    output.select { |e| !e.blank? }
  end
end
