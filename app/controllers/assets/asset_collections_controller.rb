class Assets::AssetCollectionsController < AssetsController
  before_action :get_asset

  def county_collection
    collection = District.where(district_type: DistrictType.find_by(name: 'County'), state: @asset.state).pluck(:id, :name).map{|pair| {value: "#{pair[0]}", text: "#{pair[1].gsub("'"){"\\'"}}"}}
    collection.unshift({value: '', text: ''}) if params[:include_blank]

    respond_to do |format|
      format.json { render json: collection }
    end
  end

  def mode_collection
    inactive_types = FtaModeType.where(active: false).pluck(:id)
    if @asset.is_a? RevenueVehicle
      exclude_ids = inactive_types unless (is_secondary ? (inactive_types.include? @asset.secondary_fta_mode_type_id) : (inactive_types.include? @asset.primary_fta_mode_type_id))
      if mode_or_service_match
        if @asset.secondary_fta_mode_type_id != @asset.primary_fta_mode_type_id
          (exclude_ids ||= []) << is_secondary ? @asset.primary_fta_mode_type_id : @asset.secondary_fta_mode_type_id
        end
      end
    else
      exclude_ids = inactive_types unless (is_secondary ? (@asset.secondary_fta_mode_type_ids.any?{|m| inactive_types.include?(m)}) : (inactive_types.include? @asset.primary_fta_mode_type_id))
      (exclude_ids ||= []) << (is_secondary ? @asset.primary_fta_mode_type_id : @asset.secondary_fta_mode_type_ids)
    end

    render_collection(FtaModeType, exclude_ids&.flatten, params[:sort])
  end
  def service_collection
    inactive_types = FtaServiceType.where(active: false).pluck(:id)
    exclude_ids = inactive_types unless (is_secondary ? (inactive_types.include? @asset.secondary_fta_service_type_id) : (inactive_types.include? @asset.primary_fta_service_type_id))
    if mode_or_service_match
      if @asset.secondary_fta_service_type_id != @asset.primary_fta_service_type_id
        (exclude_ids ||= []) << is_secondary ? @asset.primary_fta_service_type_id : @asset.secondary_fta_service_type_id
      end
    end

    render_collection(FtaServiceType, exclude_ids)
  end

  protected

  def is_secondary
    params[:type] == 'secondary'
  end

  def mode_or_service_match
    # for RevenueVehicle only, need to compare the combo of mode && service_type to secondary_mode && secondary_service_type
    (@asset.primary_fta_mode_type_id && @asset.primary_fta_mode_type_id == @asset.secondary_fta_mode_type_id) || 
    (@asset.primary_fta_service_type_id && @asset.primary_fta_service_type_id == @asset.secondary_fta_service_type_id)
  end

  def render_collection(klass, exclude_ids, sort = nil)
    klass_ = klass.to_s.underscore
    
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