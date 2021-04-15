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

  # called when the user wants to delete an asset
  def destroy

    @asset = TransitAsset.find_by(object_key: params[:id])
    # make sure we can find the asset we are supposed to be removing and that it belongs to us.
    if @asset.nil?
      redirect_to(root_path, :flash => { :alert => t(:error_404) })
      return
    end

    fta_asset_class_code = @asset.fta_asset_class.code
    # Destroy this asset, call backs to remove each associated object will be made
    @asset.transam_asset.destroy

    notify_user(:notice, "Asset was successfully removed.")

    respond_to do |format|
      format.html { redirect_to(transit_assets_path(fta_asset_class_code: fta_asset_class_code)) }
      format.json { head :no_content }
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
