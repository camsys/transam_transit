AssetsController.class_eval do

  # returns a list of assets for an index view (index, map) based on user selections. Called after
  # a call to set_view_vars
  def get_assets

    @fta_asset_class_ids = params[:fta_asset_class_id]
    @fta_asset_class_id = @fta_asset_class_ids.to_i

    asset_class = FtaAssetClass.find_by(id: @fta_asset_class_id)

    unless asset_class.nil?

      if asset_class.class_name == 'RevenueVehicle'
        # klass = RevenueVehicleAssetTableView.includes(:revenue_vehicle, :policy).where(transit_asset_fta_asset_class_id: @fta_asset_class_id)
        query = RevenueVehicleAssetTableView.includes(:revenue_vehicle, :policy).where(transit_asset_fta_asset_class_id: @fta_asset_class_id)
      end
      if asset_class.class_name == 'ServiceVehicle'
        query = ServiceVehicleAssetTableView.includes(:service_vehicle, :policy)
                    .where(fta_asset_class_id: @fta_asset_class_id)
      end
      if asset_class.class_name == 'CapitalEquipment'
        query = CapitalEquipmentAssetTableView.includes(:capital_equipment, :policy).where(fta_asset_class_id: @fta_asset_class_id)
      end
      if asset_class.class_name == 'Facility'
        query = FacilityPrimaryAssetTableView.includes(:facility, :policy)
                    .where(fta_asset_class_id: @fta_asset_class_id)
      end
      if asset_class.class_name == 'Guideway' || asset_class.class_name == 'PowerSignal' || asset_class.class_name == 'Track'
        query = InfrastructureAssetTableView.includes(:infrastructure, :policy)
                    .where(fta_asset_class_id: @fta_asset_class_id)
      end
    end

    if query.nil?
      query = RevenueVehicleAssetTableView.where(transit_asset_fta_asset_class_id: 1)
    end

    # We only want disposed assets on export
    unless @fmt == 'xls'
      query = query.where(transam_asset_disposition_date: nil)
    end

    # Create a class instance of the asset type which can be used to perform
    # active record queries
    @asset_class = query.name
    @view = "transit_asset_index"

    # here we build the query one clause at a time based on the input params
    unless @org_id == 0
      query = query.where(organization_id: @org_id)
    else
      query = query.where(organization_id: @organization_list)
    end

    unless @id_filter_list.blank?
      query = query.where(object_key: @id_filter_list)
    end

    if @transferred_assets
      query = query.where('asset_tag = object_key')
    else
      query = query.where('asset_tag != object_key')
    end

    unless @spatial_filter.blank?
      gis_service = GisService.new
      search_box = gis_service.search_box_from_bbox(@spatial_filter)
      wkt = "#{search_box.as_wkt}"
      query = query.where('MBRContains(GeomFromText("' + wkt + '"), geometry) = ?', [1])
    end

    # See if we got an asset group. If we did then we can
    # use the asset group collection to filter on instead of creating
    # a new query. This is kind of a hack but works!
    unless @asset_group.blank?
      query = query.joins(:asset_groups).where(asset_groups: {object_key: @asset_group})
    end

    # Search for only early dispostion proposed assets if flag is on
    if @early_disposition
      query = query.joins(:early_disposition_requests).where(asset_events: {state: 'new'})
    end

    # @total_results = query.count
    return query
  end

  def index_rows_as_json
    multi_sort = params[:multiSort]

    if multi_sort.nil?

      sort_name = format_methods_to_sort_order(params[:sort])

      sorting_string = "#{sort_name} #{params[:order]}"

    else

      sorting = []

      multi_sort.each { |x|

        sort_name = format_methods_to_sort_order(x[1]['sortName'])

        sorting << "#{sort_name} #{x[1]['sortOrder']}"
      }
      sorting_string = sorting.join(' , ')

    end

    @assets.order(sorting_string.to_s).limit(params[:limit]).offset(params[:offset]).as_json(user: current_user, include_early_disposition: @early_disposition)
  end

  def format_methods_to_sort_order(sort_name)
    return RevenueVehicleAssetTableView.format_methods_to_sort_order_columns(sort_name)
  end
end
