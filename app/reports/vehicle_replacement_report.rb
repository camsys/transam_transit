#------------------------------------------------------------------------------
#
# Vehicle Replacement Report
#
# Generates a report of vehicles that are scheduled to be replaced in a
# selected planning year
#
#------------------------------------------------------------------------------
class VehicleReplacementReport < AbstractReport

  # include the fiscal year mixin
  include FiscalYear

  attr_accessor :fy_year, :asset_subtype_id

  def initialize(attributes = {})
    super(attributes)
    @service = AssetDispositionService.new
  end

  # returns summary of count and cost for assets to be disposed by fiscal year, type, and subtype
  def get_data(organization_id_list, params)

    # Check to see if we got an asset sub type to filter by
    asset_subtype_id =  @asset_subtype_id ? @asset_subtype_id.to_i : 0

    # Check to see if we got an asset sub type to filter by
    fiscal_year =  @fy_year ? @fy_year.to_i : current_planning_year_year

    output = AssetDispositionReportPresenter.new
    output.fy = fiscal_year
    output.assets = @service.disposition_list(organization_id_list, fiscal_year)

    return output
  end
end
