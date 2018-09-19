AssetEventsController.class_eval do

  def add_asset_breadcrumbs
    add_breadcrumb "#{@asset.fta_asset_category}", '#'
    add_breadcrumb "#{@asset.fta_asset_class}", inventory_index_path(:asset_type => 0, :asset_subtype => 0, :asset_group => 0, :fta_asset_class_id => @asset.fta_asset_class.id)
    add_breadcrumb @asset.asset_tag, inventory_path(@asset)
  end
  
end
