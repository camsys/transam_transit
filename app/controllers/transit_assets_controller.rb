class TransitAssetsController < OrganizationAwareController

  def index
     @fta_asset_class = FtaAssetClass.find_by(code: params[:fta_asset_class_code])
     respond_to do |format|
      format.html
    end
  end

  #-----------------------------------------------------------------------------
  # TODO: MOST of this will be moved to a shareable module
  #-----------------------------------------------------------------------------
  def table
    code = params[:fta_asset_class_code]

    case code
    when 'bus', 'rail_car', 'ferry', 'other_passenger_vehicle'
      response = revenue_vehicles_table
    when 'track'
      response = track_table
    when 'guideway'
      response = guideway_table
    when 'power_signal'
      response = power_signal_table
    when 'capital_equipment'
      response = equipment_table
    when 'service_vehicle'
      response = service_vehicle_table
    else
      response = {count: 0, rows: []}
    end

    render status: 200, json: response
  end

  def service_vehicle_table
    assets = ServiceVehicle.non_revenue
    page = (table_params[:page] || 0).to_i
    page_size = (table_params[:page_size] || assets.count).to_i
    search = (table_params[:search]) 
    offset = page*page_size

    query = nil 
    if search
      search_string = "%#{search}%"
      search_year = (is_number? search) ? search.to_i : nil  
      query = query_builder(search_string, search_year)
            .or(org_query search_string)
            .or(manufacturer_query search_string)
            .or(manufacturer_model_query search_string)
            .or(fta_equipment_type_query search_string)
            .or(asset_subtype_query search_string)

      assets = ServiceVehicle.non_revenue.joins('left join organizations on organization_id = organizations.id')
               .joins('left join manufacturers on manufacturer_id = manufacturers.id')
               .joins('left join manufacturer_models on manufacturer_model_id = manufacturer_models.id')
               .joins('left join fta_equipment_types on fta_type_id = fta_equipment_types.id')
               .joins('left join asset_subtypes on asset_subtype_id = asset_subtypes.id')
               .where(query).where(transam_assetible_type: 'TransitAsset')
    else
      assets = ServiceVehicle.non_revenue
    end

    asset_table = assets.offset(offset).limit(page_size).map{ |a| a.rowify }
    return {count: assets.count, rows: asset_table}
  end

  def equipment_table
    assets = CapitalEquipment.all 
    page = (table_params[:page] || 0).to_i
    page_size = (table_params[:page_size] || assets.count).to_i
    search = (table_params[:search]) 
    offset = page*page_size

    query = nil 
    if search
      search_string = "%#{search}%"
      search_year = (is_number? search) ? search.to_i : nil  
      query = transit_asset_query_builder(search_string, search_year)
            .or(org_query search_string)
            .or(manufacturer_query search_string)
            .or(manufacturer_model_query search_string)
            .or(fta_equipment_type_query search_string)
            .or(asset_subtype_query search_string)

      assets = CapitalEquipment.joins('left join organizations on organization_id = organizations.id')
               .joins('left join manufacturers on manufacturer_id = manufacturers.id')
               .joins('left join manufacturer_models on manufacturer_model_id = manufacturer_models.id')
               .joins('left join fta_equipment_types on fta_type_id = fta_equipment_types.id')
               .joins('left join asset_subtypes on asset_subtype_id = asset_subtypes.id')
               .where(query).where(transam_assetible_type: 'TransitAsset')
    else
      assets = CapitalEquipment.all 
    end

    asset_table = assets.offset(offset).limit(page_size).map{ |a| a.rowify }
    return {count: assets.count, rows: asset_table}
  end

  def track_table
    tracks = Track.all
    page = (table_params[:page] || 0).to_i
    page_size = (table_params[:page_size] || tracks.count).to_i
    search = (table_params[:search]) 
    offset = page*page_size

    query = nil 
    if search
      search_string = "%#{search}%"
      query = infrastructure_query_builder(search_string)
              .or(org_query search_string)
              .or(asset_subtype_query search_string)
              .or(infrastructure_division_query search_string)
              .or(infrastructure_subdivision_query search_string)
              .or(infrastructure_track_query search_string)
              .or(infrastructure_segment_type_query search_string)

      tracks = Track.joins('left join organizations on organization_id = organizations.id')
               .joins('left join asset_subtypes on asset_subtype_id = asset_subtypes.id')
               .joins('left join infrastructure_divisions on infrastructure_division_id = infrastructure_divisions.id')
               .joins('left join infrastructure_subdivisions on infrastructure_subdivision_id = infrastructure_subdivisions.id')
               .joins('left join infrastructure_tracks on infrastructure_track_id = infrastructure_tracks.id')
               .joins('left join infrastructure_segment_types on infrastructure_segment_type_id = infrastructure_segment_types.id')
               .where(query)
    else
      tracks = Track.all 
    end
    
    asset_table = tracks.offset(offset).limit(page_size).map{ |a| a.rowify }
    
    return {count: tracks.count, rows: asset_table}
  end

  def guideway_table
    guideways = Guideway.all
    page = (table_params[:page] || 0).to_i
    page_size = (table_params[:page_size] || guideways.count).to_i
    search = (table_params[:search]) 
    offset = page*page_size

    query = nil 
    if search
      search_string = "%#{search}%"
      num_tracks = (is_number? search) ? search.to_i : nil  
      query = infrastructure_query_builder(search_string, num_tracks)
              .or(org_query search_string)
              .or(asset_subtype_query search_string)
              .or(infrastructure_division_query search_string)
              .or(infrastructure_subdivision_query search_string)
              .or(infrastructure_segment_type_query search_string)

      guideways = Guideway.joins('left join organizations on organization_id = organizations.id')
               .joins('left join asset_subtypes on asset_subtype_id = asset_subtypes.id')
               .joins('left join infrastructure_divisions on infrastructure_division_id = infrastructure_divisions.id')
               .joins('left join infrastructure_subdivisions on infrastructure_subdivision_id = infrastructure_subdivisions.id')
               .joins('left join infrastructure_segment_types on infrastructure_segment_type_id = infrastructure_segment_types.id')
               .where(query)
    end
    
    asset_table = guideways.offset(offset).limit(page_size).map{ |a| a.rowify }
    
    return {count: guideways.count, rows: asset_table}
  end

  def power_signal_table
    assets = PowerSignal.all
    page = (table_params[:page] || 0).to_i
    page_size = (table_params[:page_size] || assets.count).to_i
    search = (table_params[:search]) 
    offset = page*page_size

    query = nil 
    if search
      search_string = "%#{search}%"
      query = infrastructure_query_builder(search_string)
              .or(org_query search_string)
              .or(asset_subtype_query search_string)
              .or(infrastructure_division_query search_string)
              .or(infrastructure_subdivision_query search_string)
              .or(infrastructure_track_query search_string)
              .or(infrastructure_segment_type_query search_string)

      assets = PowerSignal.joins('left join organizations on organization_id = organizations.id')
               .joins('left join asset_subtypes on asset_subtype_id = asset_subtypes.id')
               .joins('left join infrastructure_divisions on infrastructure_division_id = infrastructure_divisions.id')
               .joins('left join infrastructure_subdivisions on infrastructure_subdivision_id = infrastructure_subdivisions.id')
               .joins('left join infrastructure_tracks on infrastructure_track_id = infrastructure_tracks.id')
               .joins('left join infrastructure_segment_types on infrastructure_segment_type_id = infrastructure_segment_types.id')
               .where(query)
    else
      assets = PowerSignal.all 
    end
    
    asset_table = assets.offset(offset).limit(page_size).map{ |a| a.rowify }
    
    return {count: assets.count, rows: asset_table}
  end

  def revenue_vehicles_table
    fta_asset_class = FtaAssetClass.find_by(code: params[:fta_asset_class_code])
    fta_asset_class_id = fta_asset_class.id 
    vehicles = RevenueVehicle.where(fta_asset_class_id: fta_asset_class_id) 
    page = (table_params[:page] || 0).to_i
    page_size = (table_params[:page_size] || vehicles.count).to_i
    search = (table_params[:search]) 
    offset = page*page_size

    query = nil 
    if search
      search_string = "%#{search}%"
      search_year = (is_number? search) ? search.to_i : nil  

      query = (query_builder(search_string, search_year))
              .or(org_query search_string)
              .or(manufacturer_query search_string)
              .or(fta_vehicle_type_query search_string)
              .or(asset_subtype_query search_string)
              .or(esl_category_query search_string)

      vehicles = RevenueVehicle.joins('left join organizations on organization_id = organizations.id')
                               .joins('left join manufacturers on manufacturer_id = manufacturers.id')
                               .joins('left join fta_vehicle_types on fta_type_id = fta_vehicle_types.id')
                               .joins('left join asset_subtypes on asset_subtype_id = asset_subtypes.id')
                               .joins('left join esl_categories on esl_category_id = esl_categories.id')
                               .where(fta_asset_class_id: fta_asset_class_id)
                               .where(organization_id: @organization_list).where(query)

      asset_table =  vehicles.offset(offset).limit(page_size).map{ |a| a.very_specific.rowify }

    else 
      asset_table = RevenueVehicle.where(fta_asset_class_id: fta_asset_class_id).offset(offset).limit(page_size).map{ |a| a.very_specific.rowify }
    end
    
    return {count: vehicles.count, rows: asset_table}
  
  end 

  protected

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

  def query_builder search_string, search_year 
    query = TransamAsset.arel_table[:asset_tag].matches(search_string)
            .or(TransamAsset.arel_table[:other_manufacturer_model].matches(search_string))
            .or(ServiceVehicle.arel_table[:serial_number].matches(search_string))

    if search_year 
      query = query.or(TransamAsset.arel_table[:manufacture_year].matches(search_year))
    end

    query 
  end

  private

  def table_params
    params.permit(:page, :page_size, :search, :fta_asset_class_id)
  end


end
