class TransitQueryFiltersController < QueryFiltersController
  def facilities
    render json: Facility.pluck("transam_assets.id", :facility_name).map{|d| {id: d[0], name: d[1]}}
  end
end