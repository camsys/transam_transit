class TransitAssetsController < OrganizationAwareController

  include TableTools

  def index
     @fta_asset_class = FtaAssetClass.find_by(code: params[:fta_asset_class_code])
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
    params.permit(:page, :page_size, :search, :fta_asset_class_id, :sort_column, :sort_order)
  end


end
