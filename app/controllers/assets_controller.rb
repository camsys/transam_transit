class AssetsController < OrganizationAwareController

  def table_table
    vehicle_table =  RevenueVehicle.all.limit(10).map{ |rv| rv.rowify }
    render status: 200, json: {count: 10, rows: vehicle_table}
  end

  #-----------------------------------------------------------------------------
  # TODO: MOST of this will be moved to a shareable module
  #-----------------------------------------------------------------------------
  def table
    count = RevenueVehicle.where(fta_asset_class_id: 1).count #Buses Only 
    page = (table_params[:page] || 0).to_i
    page_size = (table_params[:page_size] || count).to_i
    search = (table_params[:search])
    offset = page*page_size

    query = nil 
    if search
      searchable_columns = [:asset_id] 
      search_string = "%#{search}%"
      search_year = (is_number? search) ? search.to_i : nil  

      #org_query = Organization.arel_table[:name].matches(search_string).or(Organization.arel_table[:short_name].matches(search_string))
      query = (query_builder(search_string, search_year)).or(org_query search_string).or(manufacturer_query search_string)

      # This does not work. TODO: find out why this doesn't work.
      #count = RevenueVehicle.joins(:organizations).where(query).to_a.count 

      # TODO: This is a horrible temporary piece of code that will be replaced with the line above is corrected.
      index = 0
      vehicles = RevenueVehicle.joins('left join organizations on organization_id = organizations.id')
                               .joins('left join manufacturers on manufacturer_id = manufacturers.id')
                               .where(organization_id: @organization_list).where(query)
      #RevenueVehicle.joins(:organization).where(organization_id: @organization_list).where(query).each do |not_used|
      #RevenueVehicle.where(fta_asset_class_id: 1).where(query).each do |not_used|
      vehicles.each do |not_used|
        index += 1 
      end
      count = index  

      asset_table =  vehicles.offset(offset).limit(page_size).map{ |a| a.very_specific.rowify }
    else 
      asset_table = RevenueVehicle.offset(offset).limit(page_size).map{ |a| a.very_specific.rowify }
    end
    ez_count = vehicles.nil? ? count : vehicles.count 
    render status: 200, json: {count: count, ez_count: ez_count, rows: asset_table}
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

  def query_builder search_string, search_year 
    #TransitAsset.arel_table[:fta_type_type].matches(search_string).or(#
    #TransamAsset.arel_table[:asset_tag].matches(search_string).or(RevenueVehicle.arel_table[:other_fta_ownership_type].matches(search_string))
    query = TransamAsset.arel_table[:asset_tag].matches(search_string)

    if search_year 
      query = query.or(TransamAsset.arel_table[:manufacture_year].matches(search_year))
    end

    query 
    #RevenueVehicle.joins('left join organizations on organization_id = organizations.id').where(organization_id: @organization_list).where(query)?
    #RevenueVehicle.joins('left join organizations on organization_id = organizations.id').where(organizations: {short_name: 'BPT'}).where(query)
  end

  private

  def table_params
    params.permit(:page, :page_size, :search, :fta_asset_category_id)
  end


end
