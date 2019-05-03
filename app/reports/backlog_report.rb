class BacklogReport < AbstractReport

  def initialize(attributes = {})
    super(attributes)
  end    
  
  def get_data(organization_id_list, params)
    
    # Check to see if we got an asset type to sub select on
    if params[:report_filter_type] 
      report_filter_type = params[:report_filter_type].to_i
    else
      report_filter_type = 0
    end
        
    # get the list of assets for this agency
    if report_filter_type > 0

      assets = TransitAsset.where(organization_id: organization_id_list, fta_asset_category_id: report_filter_type, in_backlog: true).order(:fta_asset_category_id, :fta_asset_class_id, :fta_type_id, :asset_subtype_id)
    else
      assets = TransitAsset.where(organization_id: organization_id_list, in_backlog: true).order(:fta_asset_category_id, :fta_asset_class_id, :fta_type_id, :asset_subtype_id)
    end

    a = {}
    assets.find_each do |asset|
      # see if this asset sub type has been seen yet
      if a.has_key?([asset.fta_type, asset.asset_subtype])
        report_row = a[[asset.fta_type, asset.asset_subtype]]
      else
        report_row = FtaTypeAssetSubtypeReportRow.new([asset.fta_type, asset.asset_subtype])
        a[[asset.fta_type, asset.asset_subtype]] = report_row
      end
      # get the replacement cost for this item based on the current policy
      report_row.add(asset)
      end
    return a          
  end
  
end
