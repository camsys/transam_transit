class AssetsController < OrganizationAwareController

  def table_table
    vehicle_table =  RevenueVehicle.all.limit(10).map{ |rv| rv.rowify }
    render status: 200, json: {count: 10, rows: vehicle_table}
  end

  #-----------------------------------------------------------------------------
  # TODO: MOST of this will be moved to a shareable module
  #-----------------------------------------------------------------------------
  def table
    count = TransitAsset.where(fta_asset_class_id: 1).count  
    page = (table_params[:page] || 0).to_i
    page_size = (table_params[:page_size] || count).to_i
    search = (table_params[:search])
    offset = page*page_size

    query = nil 
    if search
      searchable_columns = [:asset_id] 
      search_string = "%#{search}%"
      #org_query = Organization.arel_table[:name].matches(search_string).or(Organization.arel_table[:short_name].matches(search_string))
      query = (query_builder(searchable_columns, search_string))#.or(org_query)

      # This does not work. TODO: find out why this doesn't work.
      #count = RevenueVehicle.joins(:organizations).where(query).to_a.count 

      # TODO: This is a horrible temporary piece of code that will be replaced with the line above is corrected.
      index = 0
      TransitAsset.where(fta_asset_class_id: 1).where(query).each do |not_used|
        index += 1 
      end
      count = index  

      asset_table = TransitAsset.where(query).offset(offset).limit(page_size).map{ |a| a.very_specific.rowify }
    else 
      asset_table = TransitAsset.where(fta_asset_class_id: 1).offset(offset).limit(page_size).map{ |a| a.very_specific.rowify }
    end

    render status: 200, json: {count: count, rows: asset_table}
  end

  def query_builder atts, search_string
    if atts.count <= 1
      return TransitAsset.arel_table[atts.pop].matches(search_string)
    else
      return TransitAsset.arel_table[atts.pop].matches(search_string).or(query_builder(atts, search_string))
    end
  end

  private

  def table_params
    params.permit(:page, :page_size, :search, :fta_asset_category_id)
  end


end
