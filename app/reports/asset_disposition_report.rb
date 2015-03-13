class AssetDispositionReport < AbstractAssetReport

  private
  def initialize(attributes={})
    @service = AssetEndOfLifeService.new
    super(attributes)
  end


  def get_assets(organization_id_list, fiscal_year, asset_type_id=nil, asset_subtype_id=nil )
    @service.list(organization_id_list, fiscal_year)
  end

  def set_defaults
    super
    if @fy_year
      @fy_year = @fy_year.to_i
    else 
      @fy_year = current_fiscal_year_year
    end
  end
end