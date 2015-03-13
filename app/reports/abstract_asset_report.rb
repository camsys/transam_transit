class AbstractAssetReport < AbstractReport
  # include the fiscal year mixin
  include FiscalYear
  
  attr_accessor :fy_year, :asset_subtype_id
  
  # returns assets, along with some meta-information (FY)
  def get_data(organization_id_list, params)
    
    # Check to see if we got an asset sub type to filter by
    asset_subtype_id =  @asset_subtype_id ? @asset_subtype_id.to_i : 0

    # Fiscal year gets set by concrete reports
    fiscal_year =  @fy_year.to_i

    output = AssetReportPresenter.new
    output.fy = fiscal_year
    output.assets = get_assets(organization_id_list, fiscal_year)

    return output
  end


  def initialize(attributes = {})
    super(attributes)
    set_defaults
  end

  def get_assets(organization_id_list, fiscal_year, asset_type_id=nil, asset_subtype_id=nil )
    @service.list(organization_id_list, fiscal_year, asset_type_id, asset_subtype_id)
  end

  def set_defaults
  end
end