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
    fta_asset_class = FtaAssetClass.find_by(code: params[:fta_asset_class_code])
    fta_asset_class_id = fta_asset_class.id 
    vehicles = RevenueVehicle.where(fta_asset_class_id: fta_asset_class_id) #All Buses
    page = (table_params[:page] || 0).to_i
    page_size = (table_params[:page_size] || count).to_i
    search = (table_params[:search]) 
    offset = page*page_size

    query = nil 
    if search
      search_string = "%#{search}%"
      search_year = (is_number? search) ? search.to_i : nil  

      query = (query_builder(search_string, search_year))
              .or(org_query search_string)
              .or(manufacturer_query search_string)
              .or(fta_type_query search_string)
              .or(fta_subtype_query search_string)
              .or(esl_category_query search_string)

      index = 0
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
    render status: 200, json: {count: vehicles.count, rows: asset_table}
  end

  def is_number? string
    true if Float(string) rescue false
  end

  def org_query search_string
    Organization.arel_table[:name].matches(search_string).or(Organization.arel_table[:short_name].matches(search_string))
  end

  def manufacturer_query search_string
    Manufacturer.arel_table[:name].matches(search_string).or(Manufacturer.arel_table[:code].matches(search_string))
  end

  def fta_type_query search_string
    FtaVehicleType.arel_table[:name].matches(search_string).or(FtaVehicleType.arel_table[:description].matches(search_string))
  end

  def fta_subtype_query search_string
    AssetSubtype.arel_table[:name].matches(search_string)
  end

  def esl_category_query search_string
    EslCategory.arel_table[:name].matches(search_string)
  end

  def query_builder search_string, search_year 
    query = TransamAsset.arel_table[:asset_tag].matches(search_string)
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