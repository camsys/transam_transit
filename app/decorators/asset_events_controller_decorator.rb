AssetEventsController.class_eval do
  def add_asset_breadcrumbs
    add_breadcrumb "#{@asset.fta_asset_class}", transit_assets_path(fta_asset_class_code: @asset.fta_asset_class.code)
    add_breadcrumb @asset.asset_tag, inventory_path(@asset)
  end
  
end
