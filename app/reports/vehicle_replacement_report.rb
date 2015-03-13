#------------------------------------------------------------------------------
#
# Vehicle Replacement Report
#
# Generates a report of vehicles that are scheduled to be replaced in a
# selected planning year
#
#------------------------------------------------------------------------------
class VehicleReplacementReport < AbstractAssetReport

  private
  def initialize(attributes={})
    @service = AssetEndOfLifeService.new
    super(attributes)
  end

  def get_assets(organization_id_list, fiscal_year, asset_type_id=nil, asset_subtype_id=nil )
    @service.list(organization_id_list, fiscal_year, AssetType.find_by(class_name: "Vehicle").id)
  end

  def set_defaults
    super
    if @fy_year
      @fy_year = @fy_year.to_i
    else 
      @fy_year = current_planning_year_year
    end
  end

end
