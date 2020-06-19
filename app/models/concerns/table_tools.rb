module TableTools

  ####################################################
  ## Build the Table API Response 
  ###################################################
  def build_table table, fta_asset_class_id=nil
    # Get the Default Set of Assets
    assets = join_builder table, fta_asset_class_id
    
    # Pluck out the Params
    # TODO: Remove dependency on table_params
    page = (table_params[:page] || 0).to_i
    page_size = (table_params[:page_size] || assets.count).to_i
    search = (table_params[:search]) 
    offset = page*page_size
    sort_column = params[:sort_column]
    sort_order = params[:sort_order]

    # Update the User's Sort (if included)
    if sort_column
      current_user.update_table_prefs(table, sort_column, sort_order)
    end

    # If Search Param is included, filter on the search.
    if search
      search_string = "%#{search}%"
      query = query_builder table, search_string
      assets = assets.where(query)
    end

    # Sort by the users preferred column
    assets = assets.order(current_user.table_sort_string table)

    # Rowify everything.
    asset_table = assets.offset(offset).limit(page_size).map{ |a| a.rowify }
    return {count: assets.count, rows: asset_table}
  end


  ####################################################
  ## Join Logic for Every Table
  ###################################################
  def join_builder table, fta_asset_class_id=nil
    case table 
    when :track
      return Track.joins('left join organizations on organization_id = organizations.id')
             .joins('left join asset_subtypes on asset_subtype_id = asset_subtypes.id')
             .joins('left join infrastructure_divisions on infrastructure_division_id = infrastructure_divisions.id')
             .joins('left join infrastructure_subdivisions on infrastructure_subdivision_id = infrastructure_subdivisions.id')
             .joins('left join infrastructure_tracks on infrastructure_track_id = infrastructure_tracks.id')
             .joins('left join infrastructure_segment_types on infrastructure_segment_type_id = infrastructure_segment_types.id')
             .where(organization_id: @organization_list)
    when :guideway 
      return Guideway.joins('left join organizations on organization_id = organizations.id')
            .joins('left join asset_subtypes on asset_subtype_id = asset_subtypes.id')
            .joins('left join infrastructure_divisions on infrastructure_division_id = infrastructure_divisions.id')
            .joins('left join infrastructure_subdivisions on infrastructure_subdivision_id = infrastructure_subdivisions.id')
            .joins('left join infrastructure_segment_types on infrastructure_segment_type_id = infrastructure_segment_types.id')
            .where(organization_id: @organization_list)
    when :power_signal
      return PowerSignal.joins('left join organizations on organization_id = organizations.id')
            .joins('left join asset_subtypes on asset_subtype_id = asset_subtypes.id')
            .joins('left join infrastructure_divisions on infrastructure_division_id = infrastructure_divisions.id')
            .joins('left join infrastructure_subdivisions on infrastructure_subdivision_id = infrastructure_subdivisions.id')
            .joins('left join infrastructure_tracks on infrastructure_track_id = infrastructure_tracks.id')
            .joins('left join infrastructure_segment_types on infrastructure_segment_type_id = infrastructure_segment_types.id')
            .where(organization_id: @organization_list)
    when :capital_equipment
      return CapitalEquipment.joins('left join organizations on organization_id = organizations.id')
            .joins('left join manufacturers on manufacturer_id = manufacturers.id')
            .joins('left join manufacturer_models on manufacturer_model_id = manufacturer_models.id')
            .joins('left join fta_equipment_types on fta_type_id = fta_equipment_types.id')
            .joins('left join asset_subtypes on asset_subtype_id = asset_subtypes.id')
            .where(transam_assetible_type: 'TransitAsset')
            .where(organization_id: @organization_list)
    when :service_vehicle
      return ServiceVehicle.non_revenue.joins('left join organizations on organization_id = organizations.id')
            .joins('left join manufacturers on manufacturer_id = manufacturers.id')
            .joins('left join manufacturer_models on manufacturer_model_id = manufacturer_models.id')
            .joins('left join fta_equipment_types on fta_type_id = fta_equipment_types.id')
            .joins('left join asset_subtypes on asset_subtype_id = asset_subtypes.id')
            .where(transam_assetible_type: 'TransitAsset')
            .where(organization_id: @organization_list)
    when :bus, :rail_car, :ferry, :other_passenger_vehicle
      return RevenueVehicle.joins('left join organizations on organization_id = organizations.id')
           .joins('left join manufacturers on manufacturer_id = manufacturers.id')
           .joins('left join fta_vehicle_types on fta_type_id = fta_vehicle_types.id')
           .joins('left join asset_subtypes on asset_subtype_id = asset_subtypes.id')
           .joins('left join esl_categories on esl_category_id = esl_categories.id')
           .where(fta_asset_class_id: fta_asset_class_id)
           .where(organization_id: @organization_list)
    when :passenger_facility, :maintenance_facility, :admin_facility, :parking_facility
      return Facility.joins('left join organizations on organization_id = organizations.id')
             .joins('left join fta_equipment_types on fta_type_id = fta_equipment_types.id')
             .joins('left join asset_subtypes on asset_subtype_id = asset_subtypes.id')
             .where(fta_asset_class_id: fta_asset_class_id)
             .where(transam_assetible_type: 'TransitAsset')
             .where(organization_id: @organization_list)
    end
  end

  ####################################################
  ## Query Logic for Every Table
  ###################################################
  def query_builder table, search_string
    num_tracks = nil
    search_year = nil 
    case table 
    when :track
      return infrastructure_query_builder(search_string)
            .or(org_query search_string)
            .or(asset_subtype_query search_string)
            .or(infrastructure_division_query search_string)
            .or(infrastructure_subdivision_query search_string)
            .or(infrastructure_track_query search_string)
            .or(infrastructure_segment_type_query search_string)
    when :guideway
      return infrastructure_query_builder(search_string, num_tracks)
            .or(org_query search_string)
            .or(asset_subtype_query search_string)
            .or(infrastructure_division_query search_string)
            .or(infrastructure_subdivision_query search_string)
            .or(infrastructure_segment_type_query search_string)
    when :power_signal
      return infrastructure_query_builder(search_string)
            .or(org_query search_string)
            .or(asset_subtype_query search_string)
            .or(infrastructure_division_query search_string)
            .or(infrastructure_subdivision_query search_string)
            .or(infrastructure_track_query search_string)
            .or(infrastructure_segment_type_query search_string)
    when :capital_equipment
      return transit_asset_query_builder(search_string, search_year)
            .or(org_query search_string)
            .or(manufacturer_query search_string)
            .or(manufacturer_model_query search_string)
            .or(fta_equipment_type_query search_string)
            .or(asset_subtype_query search_string)
    when :service_vehicle
      return service_vehicle_query_builder(search_string, search_year)
            .or(org_query search_string)
            .or(manufacturer_query search_string)
            .or(manufacturer_model_query search_string)
            .or(fta_equipment_type_query search_string)
            .or(asset_subtype_query search_string)
    when :bus, :rail_car, :ferry, :other_passenger_vehicle
      return service_vehicle_query_builder(search_string, search_year)
            .or(org_query search_string)
            .or(manufacturer_query search_string)
            .or(fta_vehicle_type_query search_string)
            .or(asset_subtype_query search_string)
            .or(esl_category_query search_string)
    when :passenger_facility, :maintenance_facility, :admin_facility, :parking_facility
      return transit_asset_query_builder(search_string, search_year)
            .or(org_query search_string)
            .or(fta_equipment_type_query search_string)
            .or(asset_subtype_query search_string)
    end
  end 

  ####################################################
  ## Query Helpers
  ###################################################
  def is_number? string
    true if Float(string) rescue false
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

  def infrastructure_query_builder search_string, num_tracks=nil
    query = TransamAsset.arel_table[:asset_tag].matches(search_string)
            .or(TransamAsset.arel_table[:description].matches(search_string))
            .or(Infrastructure.arel_table[:from_line].matches(search_string))
            .or(Infrastructure.arel_table[:to_line].matches(search_string))
            .or(Infrastructure.arel_table[:from_segment].matches(search_string))
            .or(Infrastructure.arel_table[:to_segment].matches(search_string))
            .or(Infrastructure.arel_table[:relative_location].matches(search_string))
            .or(Infrastructure.arel_table[:num_tracks].matches(search_string))
    
    if num_tracks
      query = query.or(Infrastructure.arel_table[:num_tracks].matches(num_tracks))
    end

    query
  end

  # Used for Capital Equipment
  def transit_asset_query_builder search_string, search_year 
    query = TransamAsset.arel_table[:asset_tag].matches(search_string)
            .or(TransamAsset.arel_table[:other_manufacturer_model].matches(search_string))
            .or(TransamAsset.arel_table[:description].matches(search_string))

    if search_year 
      query = query.or(TransamAsset.arel_table[:manufacture_year].matches(search_year))
    end

    query 
  end

  def service_vehicle_query_builder search_string, search_year 
    query = TransamAsset.arel_table[:asset_tag].matches(search_string)
            .or(TransamAsset.arel_table[:other_manufacturer_model].matches(search_string))
            .or(ServiceVehicle.arel_table[:serial_number].matches(search_string))

    if search_year 
      query = query.or(TransamAsset.arel_table[:manufacture_year].matches(search_year))
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