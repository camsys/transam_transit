class Assets::AssetCollectionsController < AssetsController
  before_action :get_asset

  def county_collection
    collection = District.where(district_type: DistrictType.find_by(name: 'County')).pluck(:name,:state).map{|d|[d[0],d[0],{'data-state':d[1], style: d[1]==SystemConfig.instance.default_state_code ? 'display:block;padding-bottom:2px;' : 'display:none;'}]}
    collection.unshift({value: '', text: ''}) if params[:include_blank]

    respond_to do |format|
      format.json { render json: collection }
    end
  end

  def mode_collection
    inactive_types = FtaModeType.where(active: false).pluck(:id)

    primary_fta_mode_type_id = params[:primary_fta_mode_type_id] || @asset.primary_fta_mode_type_id
    secondary_fta_mode_type_id = params[:secondary_fta_mode_type_id] || (@asset.is_a?(RevenueVehicle) ? @asset.secondary_fta_mode_type_id : @asset.secondary_fta_mode_type_ids)
    primary_fta_service_type_id = params[:primary_fta_service_type_id] || @asset.try(:primary_fta_service_type_id)
    secondary_fta_service_type_id = params[:secondary_fta_service_type_id] || @asset.try(:secondary_fta_service_type_id)

    if @asset.is_a? RevenueVehicle
      exclude_ids = inactive_types.select{|x| x != (is_secondary ? secondary_fta_mode_type_id : primary_fta_mode_type_id) }
      if mode_or_service_match(primary_fta_mode_type_id, secondary_fta_mode_type_id, primary_fta_service_type_id, secondary_fta_service_type_id)
        if secondary_fta_mode_type_id != primary_fta_mode_type_id
          exclude_ids << (is_secondary ? primary_fta_mode_type_id : secondary_fta_mode_type_id)
        end
      end
    else
      exclude_ids = inactive_types.select{|x| (is_secondary ? !(secondary_fta_mode_type_id.include?(x)) : x != primary_fta_mode_type_id)}
      exclude_ids<< (is_secondary ? primary_fta_mode_type_id : secondary_fta_mode_type_id)
    end

    puts "===="
    puts exclude_ids.inspect

    render_collection(FtaModeType, exclude_ids&.flatten, params[:sort])
  end
  def service_collection
    primary_fta_mode_type_id = params[:primary_fta_mode_type_id] || @asset.primary_fta_mode_type_id
    secondary_fta_mode_type_id = params[:secondary_fta_mode_type_id] || (@asset.is_a?(RevenueVehicle) ? @asset.secondary_fta_mode_type_id : @asset.secondary_fta_mode_type_ids)
    primary_fta_service_type_id = params[:primary_fta_service_type_id] || @asset.primary_fta_service_type_id
    secondary_fta_service_type_id = params[:secondary_fta_service_type_id] || @asset.secondary_fta_service_type_id

    inactive_types = FtaServiceType.where(active: false).pluck(:id)
    exclude_ids = inactive_types.select{|x| x != (is_secondary ? secondary_fta_service_type_id : primary_fta_service_type_id) }
    if mode_or_service_match(primary_fta_mode_type_id, secondary_fta_mode_type_id, primary_fta_service_type_id, secondary_fta_service_type_id)
      if secondary_fta_service_type_id != primary_fta_service_type_id
        exclude_ids << (is_secondary ? primary_fta_service_type_id : secondary_fta_service_type_id)
      end
    end

    puts "===="
    puts exclude_ids.inspect

    render_collection(FtaServiceType, exclude_ids)
  end

  protected

  def is_secondary
    params[:type] == 'secondary'
  end

  def mode_or_service_match(primary_fta_mode_type_id, secondary_fta_mode_type_id, primary_fta_service_type_id, secondary_fta_service_type_id)
    # for RevenueVehicle only, need to compare the combo of mode && service_type to secondary_mode && secondary_service_type
    (primary_fta_mode_type_id && primary_fta_mode_type_id == secondary_fta_mode_type_id) ||
    (primary_fta_service_type_id && primary_fta_service_type_id == secondary_fta_service_type_id)
  end

  def render_collection(klass, exclude_ids, sort = nil)
    klass_ = klass.to_s.underscore

    exclude_ids.reject!(&:blank?)
    collection = klass.where.not(id: exclude_ids)

    if sort
      collection = collection.sort_by{|i| i.send(sort)}
    end

    collection = collection.pluck(:id, :code, :name).map{|pair| {value: "#{pair[0]}", text: "#{pair[1]} - #{pair[2].gsub("'"){"\\'"}}"}}
    collection.unshift({value: '', text: ''}) if params[:include_blank]

    respond_to do |format|
      format.json { render json: collection }
    end
  end
end