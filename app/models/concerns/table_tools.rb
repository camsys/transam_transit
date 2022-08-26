module TableTools

  ####################################################
  ## Build the Table API Response 
  ###################################################
  def build_table table, fta_asset_class_id=nil
    # Get the Default Set of Assets
    assets = join_builder(table, fta_asset_class_id).not_in_transfer

    # Pluck out the Params
    # TODO: Remove dependency on table_params
    page = (table_params[:page] || 0).to_i
    page_size = (table_params[:page_size] || assets.count).to_i
    search = (table_params[:search]) 
    offset = page*page_size
    sort_column = params[:sort_column]
    sort_order = params[:sort_order]
    columns = params[:columns]

    # Update the User's Sort (if included)
    if sort_column or columns 
      current_user.update_table_prefs(table, sort_column, sort_order, columns)
    end

    # If Search Params is included, filter on the search.
    if search.present?
      query = query_builder table, search
      assets = assets.where(query)
    end

    # Sort by the users preferred column
    unsorted_assets = assets
    count = nil
    begin 
      assets = assets.order(current_user.table_sort_string table)
      count = assets.count
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.error e.message
      # If an invalid column was sent, unsort and delete the new preference
      assets = unsorted_assets
      current_user.delete_table_prefs(table)
      count = assets.count
    end

    # Rowify everything.
    selected_columns = current_user.column_preferences table
    asset_table = assets.offset(offset).limit(page_size).map{ |a| a.rowify(selected_columns) }
    return {count: count, rows: asset_table}
  end


  ####################################################
  ## Join Logic for Every Table
  ###################################################
  def join_builder table, fta_asset_class_id=nil
    case table
    when :track, :guideway, :power_signal, :capital_equipment, :service_vehicle
      klass = table.to_s.camelize.constantize
    when :bus, :rail_car, :ferry, :other_passenger_vehicle
      klass = RevenueVehicle
    when :passenger_facility, :maintenance_facility, :admin_facility, :parking_facility
      klass = Facility
    end

    # Special cases
    case table
    when :service_vehicle
      klass = klass.non_revenue
    when :capital_equipment
      # For some reason the asset_events join causes it to forget that it's transam_assetible so explicitly add
      klass = klass.joins("left outer join transam_assets on transam_assets.transam_assetible_id = transit_assets.id and transam_assets.transam_assetible_type = 'TransitAsset'")
    end      

    # Common to all assets
    disposition_event_type_id = ServiceStatusType.where(name: 'Disposed').limit(1).pluck(:id).first

    query = klass.joins('left join organizations on transam_assets.organization_id = organizations.id')
              .joins('left join asset_subtypes on transam_assets.asset_subtype_id = asset_subtypes.id')
              .joins("left join asset_events all_events on all_events.id = (select id from asset_events where asset_events.base_transam_asset_id = transam_assets.id order by event_date desc, updated_at desc, id desc limit 1)")
              .joins('left join asset_event_types on all_events.asset_event_type_id = asset_event_types.id')
              .joins("left join asset_events condition_events on condition_events.id = (select max(id) from asset_events asset_events where asset_events.transam_asset_id = transam_assets.id and asset_events.transam_asset_type = 'TransamAsset' and asset_events.asset_event_type_id = #{ConditionUpdateEvent.asset_event_type.id})")
              .joins('left join condition_types on condition_events.condition_type_id = condition_types.id')
              .joins("left join asset_events service_status_events on service_status_events.id = (select max(id) from asset_events asset_events where asset_events.base_transam_asset_id = transam_assets.id and asset_events.transam_asset_type = 'TransamAsset' and asset_events.asset_event_type_id = #{ServiceStatusUpdateEvent.asset_event_type.id})")
              .joins("left join service_status_types on service_status_types.id = (case when transam_assets.disposition_date is not null then #{disposition_event_type_id} else service_status_events.service_status_type_id end)")
              .joins("left join asset_events rebuild_rehab_events on rebuild_rehab_events.id = (select max(id) from asset_events asset_events where asset_events.base_transam_asset_id = transam_assets.id and asset_events.transam_asset_type = 'TransamAsset' and asset_events.asset_event_type_id = #{RehabilitationUpdateEvent.asset_event_type.id})")

    
    # Major asset groups
    case table
    when :track, :guideway, :power_signal
      query = query.joins('left join fta_asset_classes on fta_asset_class_id = fta_asset_classes.id')
                .joins('left join infrastructure_divisions on infrastructure_division_id = infrastructure_divisions.id')
                .joins('left join infrastructure_subdivisions on infrastructure_subdivision_id = infrastructure_subdivisions.id')
                .joins('left join infrastructure_segment_types on infrastructure_segment_type_id = infrastructure_segment_types.id')
    when :service_vehicle, :bus, :rail_car, :ferry, :other_passenger_vehicle
      query = query.joins('left join fta_asset_classes on fta_asset_class_id = fta_asset_classes.id')
                .joins('left join manufacturers on transam_assets.manufacturer_id = manufacturers.id')
                .joins('left join manufacturer_models on transam_assets.manufacturer_model_id = manufacturer_models.id')
                .joins('left join fta_vehicle_types on fta_type_id = fta_vehicle_types.id')
                .joins('left join chasses on chassis_id = chasses.id')
                .joins('left join fuel_types on fuel_type_id = fuel_types.id')
                .joins('left join organizations as operators on operator_id = operators.id')
                .joins("left join asset_events mileage_events on mileage_events.id = (select max(id) from asset_events where asset_events.base_transam_asset_id = transam_assets.id and asset_events.transam_asset_type = 'ServiceVehicle' and asset_events.asset_event_type_id = #{MileageUpdateEvent.asset_event_type.id})")
                .joins('left join transam_assets_model_names on transam_assets.transam_assetible_id=transam_assets_model_names.transam_asset_id')
    when :passenger_facility, :maintenance_facility, :admin_facility, :parking_facility
      query = query.joins('left join fta_equipment_types on fta_type_id = fta_equipment_types.id')

    end

    # Specific cases
    case table
    when :track
      query = query.joins('left join fta_track_types on fta_type_id = fta_track_types.id')
                .joins('left join infrastructure_tracks on infrastructure_track_id = infrastructure_tracks.id')
    when :guideway
      query = query.joins('left join fta_guideway_types on fta_type_id = fta_guideway_types.id')
    when :power_signal
      query = query.joins('left join fta_power_signal_types on fta_type_id = fta_power_signal_types.id')
                .joins('left join infrastructure_tracks on infrastructure_track_id = infrastructure_tracks.id')
    when :capital_equipment
      query = query.joins('left join fta_asset_classes on fta_asset_class_id = fta_asset_classes.id')
                .joins('left join manufacturers on transam_assets.manufacturer_id = manufacturers.id')
                .joins('left join manufacturer_models on transam_assets.manufacturer_model_id = manufacturer_models.id')
                .joins('left join fta_equipment_types on fta_type_id = fta_equipment_types.id')
                .joins('left join transam_assets_model_names on transam_assets.transam_assetible_id=transam_assets_model_names.transam_asset_id')
                .where(transam_assetible_type: 'TransitAsset')
    when :bus, :rail_car, :ferry, :other_passenger_vehicle
      query = query.joins('left join esl_categories on esl_category_id = esl_categories.id')
                .joins('left join fta_funding_types on fta_funding_type_id = fta_funding_types.id')
                .joins('left join fta_ownership_types on fta_ownership_type_id = fta_ownership_types.id')
                .where(fta_asset_class_id: fta_asset_class_id)
    when :passenger_facility, :maintenance_facility, :admin_facility, :parking_facility
      query = query.joins('left join fta_equipment_types on fta_type_id = fta_equipment_types.id')
                .where(fta_asset_class_id: fta_asset_class_id)
                .where(transam_assetible_type: 'TransitAsset')
    end

    query.where(organization_id: @organization_list)
  end

  ####################################################
  ## Query Logic for Every Table
  ###################################################
  def query_builder table, search
    
    # Throw on some wildcards to make search more forgiving
    search_string = "%#{search}%"

    # Check to see if the search_string is a number, if it is, also search on numerical columns
    search_number = (is_number? search) ? Float(search) : nil

    search_date = parse_date(search)

    query = nil
    case table 
    when :track
      query = infrastructure_query_builder(search_string, nil)
            .or(org_query search_string)
            .or(asset_subtype_query search_string)
            .or(infrastructure_division_query search_string)
            .or(infrastructure_subdivision_query search_string)
            .or(infrastructure_track_query search_string)
            .or(infrastructure_segment_type_query search_string)
            .or(fta_asset_class_query search_string)
    when :guideway
      query = infrastructure_query_builder(search_string, search_number)
            .or(org_query search_string)
            .or(asset_subtype_query search_string)
            .or(infrastructure_division_query search_string)
            .or(infrastructure_subdivision_query search_string)
            .or(infrastructure_segment_type_query search_string)
            .or(fta_asset_class_query search_string)
    when :power_signal
      query = infrastructure_query_builder(search_string, nil)
            .or(org_query search_string)
            .or(asset_subtype_query search_string)
            .or(infrastructure_division_query search_string)
            .or(infrastructure_subdivision_query search_string)
            .or(infrastructure_track_query search_string)
            .or(infrastructure_segment_type_query search_string)
            .or(fta_asset_class_query search_string)
    when :capital_equipment
      query = transit_asset_query_builder(search_string, search_number)
            .or(org_query search_string)
            .or(manufacturer_query search_string)
            .or(manufacturer_model_query search_string)
            .or(fta_equipment_type_query search_string)
            .or(asset_subtype_query search_string)
            .or(fta_asset_class_query search_string)
    when :service_vehicle
      query = service_vehicle_query_builder(search_string, search_number)
            .or(org_query search_string)
            .or(manufacturer_query search_string)
            .or(manufacturer_model_query search_string)
            .or(fta_vehicle_type_query search_string)
            .or(asset_subtype_query search_string)
            .or(fta_asset_class_query search_string)
            .or(chassis_query search_string)
            .or(fuel_type_query search_string)
    when :bus, :rail_car, :ferry, :other_passenger_vehicle
      query = service_vehicle_query_builder(search_string, search_number)
            .or(org_query search_string)
            .or(manufacturer_query search_string)
            .or(manufacturer_model_query search_string)
            .or(fta_vehicle_type_query search_string)
            .or(asset_subtype_query search_string)
            .or(esl_category_query search_string)
            .or(fta_asset_class_query search_string)
            .or(chassis_query search_string)
            .or(fuel_type_query search_string)
            .or(fta_funding_type_query search_string)
            .or(fta_ownership_type_query search_string)
    when :passenger_facility, :maintenance_facility, :admin_facility, :parking_facility
      query = transit_asset_query_builder(search_string, search_number)
            .or(org_query search_string)
            .or(fta_equipment_type_query search_string)
            .or(asset_subtype_query search_string)
    end
    query = query.or(TransamAsset.arel_table[:in_service_date].eq(search_date)) if search_date
    query.or(ServiceStatusType.arel_table[:name].matches(search_string))
      .or(life_cycle_action_query search_string, search_date)
      .or(term_condition_rating_query search_string, search_number)
  end 

  ####################################################
  ## Query Helpers
  ###################################################
  def is_number? string
    true if Float(string) rescue false
  end

  def parse_date string
    # Simple tests to exclude most non-dates. Date.parse is too forgiving
    return nil if (string.size < 4) || !(string =~ /^\d(\d+|\/|-)*$/)
    Date.parse(string) rescue nil
  end
  
  def org_query search_string
    Organization.arel_table[:name].matches(search_string).or(Organization.arel_table[:short_name].matches(search_string))
  end

  def manufacturer_query search_string
    Manufacturer.arel_table[:name].matches(search_string).or(Manufacturer.arel_table[:code].matches(search_string))
  end

  def manufacturer_model_query search_string
    ManufacturerModel.arel_table[:name].matches(search_string)
  end

  def fta_vehicle_type_query search_string
    FtaVehicleType.arel_table[:name].matches(search_string).or(FtaVehicleType.arel_table[:description].matches(search_string))
  end

  def fta_equipment_type_query search_string
    FtaEquipmentType.arel_table[:name].matches(search_string)
  end

  def asset_subtype_query search_string
    AssetSubtype.arel_table[:name].matches(search_string)
  end

  def esl_category_query search_string
    EslCategory.arel_table[:name].matches(search_string)
  end

  def infrastructure_division_query search_string
    InfrastructureDivision.arel_table[:name].matches(search_string)
  end

  def infrastructure_subdivision_query search_string
    InfrastructureSubdivision.arel_table[:name].matches(search_string)
  end

  def infrastructure_track_query search_string
    InfrastructureTrack.arel_table[:name].matches(search_string)
  end

  def infrastructure_segment_type_query search_string
    InfrastructureSegmentType.arel_table[:name].matches(search_string)
  end

  def fta_asset_class_query search_string 
    FtaAssetClass.arel_table[:name].matches(search_string)
  end 

  def chassis_query search_string 
    Chassis.arel_table[:name].matches(search_string)
  end 

  def fuel_type_query search_string 
    FuelType.arel_table[:name].matches(search_string)
  end 

  def fta_mode_type_query search_string 
    FtaModeType.arel_table[:name].matches(search_string)
  end

  def fta_funding_type_query search_string 
    FtaFundingType.arel_table[:name].matches(search_string)
  end

  def fta_ownership_type_query search_string
    FtaOwnershipType.arel_table[:name].matches(search_string)
  end

  def life_cycle_action_query search_string, search_date
    query = AssetEventType.arel_table[:name].matches(search_string)
    if search_date
      all_events = AssetEvent.arel_table.alias 'all_events'
      query = query.or(all_events[:event_date].eq(search_date))
    end
    query
  end

  def term_condition_rating_query search_string, search_number
    query = ConditionType.arel_table[:name].matches(search_string)
    if search_number
      condition_events = AssetEvent.arel_table.alias 'condition_events'
      query = query.or(condition_events[:assessed_rating].eq(search_number))
    end
    query
  end

  def infrastructure_query_builder search_string, search_number=nil
    query = TransamAsset.arel_table[:asset_tag].matches(search_string)
            .or(TransamAsset.arel_table[:description].matches(search_string))
            .or(Infrastructure.arel_table[:from_line].matches(search_string))
            .or(Infrastructure.arel_table[:to_line].matches(search_string))
            .or(Infrastructure.arel_table[:from_segment].matches(search_string))
            .or(Infrastructure.arel_table[:to_segment].matches(search_string))
            .or(Infrastructure.arel_table[:relative_location].matches(search_string))
            .or(Infrastructure.arel_table[:num_tracks].matches(search_string))
            .or(TransamAsset.arel_table[:external_id].matches(search_string))
            .or(TransitAsset.arel_table[:pcnt_capital_responsibility].matches(search_number))

    
    if search_number
      query = query.or(Infrastructure.arel_table[:num_tracks].matches(search_number))
                   .or(TransamAsset.arel_table[:purchase_cost].matches(search_number))
    end

    query
  end

  # Used for Capital Equipment
  def transit_asset_query_builder search_string, search_number 
    query = TransamAsset.arel_table[:asset_tag].matches(search_string)
            .or(TransamAsset.arel_table[:other_manufacturer_model].matches(search_string))
            .or(TransamAsset.arel_table[:description].matches(search_string))
            .or(TransamAsset.arel_table[:external_id].matches(search_string))
            .or(TransamAsset.arel_table[:quantity_unit].matches(search_string))
    if search_number
      query = query.or(TransamAsset.arel_table[:manufacture_year].matches(search_number))
                    .or(TransamAsset.arel_table[:quantity].matches(search_number))
                    .or(TransamAsset.arel_table[:purchase_cost].matches(search_number))
                    .or(TransitAsset.arel_table[:pcnt_capital_responsibility].matches(search_number))
    end
    query 
  end

  def service_vehicle_query_builder search_string, search_number
    query = TransamAsset.arel_table[:asset_tag].matches(search_string)
            .or(TransamAsset.arel_table[:other_manufacturer_model].matches(search_string))
            .or(ServiceVehicle.arel_table[:serial_number].matches(search_string))
            .or(TransamAsset.arel_table[:external_id].matches(search_string))
            .or(ServiceVehicle.arel_table[:license_plate].matches(search_string))
            .or(ServiceVehicle.arel_table[:vehicle_length_unit].matches(search_string))
            .or(ServiceVehicle.arel_table[:other_fuel_type].matches(search_string))
    if search_number
      mileage_events = AssetEvent.arel_table.alias 'mileage_events'

      query = query.or(TransamAsset.arel_table[:manufacture_year].eq(search_number))
                    .or(ServiceVehicle.arel_table[:vehicle_length].eq(search_number))
                    .or(TransamAsset.arel_table[:purchase_cost].eq(search_number))
                    .or(TransitAsset.arel_table[:pcnt_capital_responsibility].eq(search_number))
                    .or(ServiceVehicle.arel_table[:seating_capacity].eq(search_number))
                    .or(mileage_events[:current_mileage].eq(search_number))
    end
    query 
  end

  def facility_query_builder search_string, search_year 
    query = TransamAsset.arel_table[:asset_tag].matches(search_string)
            .or(Facility.arel_table[:facility_name].matches(search_string))
    if search_year 
      query = query.or(TransamAsset.arel_table[:manufacture_year].matches(search_year))
    end
    query 
  end

end
