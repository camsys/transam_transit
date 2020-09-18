class TransitAssetsController < OrganizationAwareController

  include TableTools

  add_breadcrumb "Home", :root_path

  def index
    @fta_asset_class = FtaAssetClass.find_by(code: params[:fta_asset_class_code])
    add_breadcrumb @fta_asset_class.fta_asset_category
    respond_to do |format|
      format.html
    end
  end

  def table
    code = params[:fta_asset_class_code]    
    fta_asset_class = FtaAssetClass.find_by(code: code)
    response = build_table(code.to_sym, fta_asset_class.id)
    render status: 200, json: response 
  end

  private

  def table_params
    params.permit(:page, :page_size, :search, :fta_asset_class_id, :sort_column, :sort_order, :columns)
  end


end
