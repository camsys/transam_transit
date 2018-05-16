class AssetFleetsController < OrganizationAwareController

  layout 'asset_fleets'

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Fleets", :asset_fleets_path

  before_action :set_asset_fleet, only: [:show, :edit, :update, :destroy, :remove_asset]

  before_action :set_form_vars, only: [:orphaned_assets, :builder]
  
  # GET /asset_fleets
  def index
    params[:sort] ||= 'ntd_id'

    @fta_asset_category = (FtaAssetCategory.find_by(id: params[:fta_asset_category_id]) || FtaAssetCategory.first)
    @asset_fleet_types = AssetFleetType.where(class_name: @fta_asset_category.asset_types.pluck(:class_name))
    # Go ahead and join with assets since almost every query requires it
    @asset_fleets = AssetFleet.where(organization_id: @organization_list, asset_fleet_type_id: @asset_fleet_types.pluck(:id)).distinct.joins(:assets)

    case @fta_asset_category.name
    when "Equipment"
      crumb = "Support Vehicles"
      @text_search_prompt = 'NTD ID/Agency Fleet ID/Fleet Name'
      include_fleet_name = true
      @vehicle_types = FtaSupportVehicleType.where(id: @asset_fleets.uniq.pluck(:fta_support_vehicle_type_id))
      use_support_vehicle_types = true
      # Disallow/map certain sort parameters
      case params[:sort]
      when 'primary_fta_service_type_id', 'active_count'
        params[:sort] = 'ntd_id'
      when 'fta_vehicle_type_id'
        params[:sort] = 'fta_support_vehicle_type_id'
      end
    else # Primarily Revenue vehicles for now
      crumb =  @fta_asset_category.to_s
      @text_search_prompt = 'RVI ID/Agency Fleet ID'
      include_fleet_name = false
      @service_types = FtaServiceType.active.all
      @vehicle_types = FtaVehicleType.where(id: @asset_fleets.uniq.pluck(:fta_vehicle_type_id))
      use_support_vehicle_types = false
      # Disallow/map certain sort parameters
      case params[:sort]
      when 'fleet_name'
        params[:sort] = 'ntd_id'
      when 'fta_support_vehicle_type_id'
        params[:sort] = 'fta_vehicle_type_id'
      end
    end
    
    case params[:sort]
    when 'organization'
      params[:sort] = 'organizations.short_name'
      @asset_fleets = @asset_fleets.joins(:organization)
    when 'ntd_id', 'agency_fleet_id', 'fleet_name'
      # Columns of asset_fleets, do nothing
    when 'primary_fta_mode_type_id'
      params[:sort] = 'assets_fta_mode_types.fta_mode_type_id'
      @asset_fleets = @asset_fleets
                      .joins("INNER JOIN assets_fta_mode_types ON assets.id = assets_fta_mode_types.asset_id")
                      .where(assets_fta_mode_types: {is_primary: true})

    when 'primary_fta_service_type_id'
      params[:sort] = 'assets_fta_service_types.fta_service_type_id'
      @asset_fleets = @asset_fleets
                      .joins("INNER JOIN assets_fta_service_types ON assets.id = assets_fta_service_types.asset_id")
                      .where(assets_fta_service_types: {is_primary: true})
    else
      # Asset field
      params[:sort] = "assets.#{params[:sort]}"
    end
    
    add_breadcrumb crumb

    # Set up filter collections
    @primary_modes = FtaModeType.where(id: AssetsFtaModeType.joins(:fta_mode_type)
                                        .where(assets_fta_mode_types: {is_primary: true}, asset_id: @asset_fleets.pluck('assets_asset_fleets.asset_id'))
                                       .uniq.pluck(:fta_mode_type_id))
    @manufacturers = Manufacturer.where(id: @asset_fleets.uniq.pluck(:manufacturer_id))
    
    # Filter results
    # Primary FTA Mode Type is particularly messy
    set_var_and_yield_if_present :primary_fta_mode_type_id do
      @asset_fleets = @asset_fleets
                      .joins("INNER JOIN assets_fta_mode_types ON assets.id = assets_fta_mode_types.asset_id")
                      .where(assets_fta_mode_types: {fta_mode_type_id: @primary_fta_mode_type_id,
                                                     is_primary: true})
    end

    # As is Primary FTA Service Type
    set_var_and_yield_if_present :primary_fta_service_type_id do
      @asset_fleets = @asset_fleets
                      .joins("INNER JOIN assets_fta_service_types ON assets.id = assets_fta_service_types.asset_id")
                      .where(assets_fta_service_types: {fta_service_type_id: @primary_fta_service_type_id,
                                                        is_primary: true})
    end

    # Drop into arel for OR of LIKE queries for text_search
    set_var_and_yield_if_present :search_text do
      ntd_id = Integer(@search_text, 10) rescue nil
      asset_fleet_table = AssetFleet.arel_table

      if ntd_id && include_fleet_name
        @asset_fleets = @asset_fleets.where(asset_fleet_table[:agency_fleet_id].matches("%#{@search_text}%")
                                             .or(asset_fleet_table[:fleet_name].matches("%#{@search_text}%"))
                                             .or(asset_fleet_table[:ntd_id].eq(ntd_id)))
      elsif ntd_id
        @asset_fleets = @asset_fleets.where(asset_fleet_table[:agency_fleet_id].matches("%#{@search_text}%")
                                             .or(asset_fleet_table[:ntd_id].eq(ntd_id)))

      elsif include_fleet_name
        @asset_fleets = @asset_fleets.where(asset_fleet_table[:agency_fleet_id].matches("%#{@search_text}%")
                                             .or(asset_fleet_table[:fleet_name].matches("%#{@search_text}%")))
      else
        @asset_fleets = @asset_fleets.where(asset_fleet_table[:agency_fleet_id].matches("%#{@search_text}%"))
      end
    end

    set_var_and_yield_if_present :fta_vehicle_type_id do
      if use_support_vehicle_types
        @asset_fleets = @asset_fleets.where(assets: {fta_support_vehicle_type_id: @fta_vehicle_type_id})
      else
        @asset_fleets = @asset_fleets.where(assets: {fta_vehicle_type_id: @fta_vehicle_type_id})
      end
    end
    
    set_var_and_yield_if_present :manufacturer_id do
      @asset_fleets = @asset_fleets.where(assets: {manufacturer_id: @manufacturer_id})
    end

    set_var_and_yield_if_present :manufacture_year do
      @asset_fleets = @asset_fleets.where(assets: {manufacture_year: @manufacture_year})
    end

    @status = params[:status] || 'Active'
    if @status == 'Active'
      @asset_fleets = @asset_fleets.where(assets: {disposition_date: nil, fta_emergency_contingency_fleet: false})
    else
      @asset_fleets = @asset_fleets
                      .where.not(id: @asset_fleets.where(assets: {disposition_date: nil, fta_emergency_contingency_fleet: false}).pluck(:id))
    end
    
    respond_to do |format|
      format.html 
      format.json {
        render :json => {
            :total => @asset_fleets.count,
            :rows =>  @asset_fleets.order("#{params[:sort]} #{params[:order]}").limit(params[:limit]).offset(params[:offset])
        }
      }
      format.xls
    end
  end

  def orphaned_assets
    # check that an order param was provided otherwise use asset_tag as the default
    params[:sort] ||= 'asset_tag'

    [:asset_type_id, :manufacturer_id, :manufacturer_model, :manufacture_year,
     :asset_subtype_id, :vehicle_type, :service_status_type_id].each do |p|
      set_var_and_yield_if_present p do
        @orphaned_assets = @orphaned_assets.where(p => params[p])
      end
    end

    set_var_and_yield_if_present :search_text do
      asset_table = Asset.arel_table

      @orphaned_assets = @orphaned_assets
                         .where(asset_table[:asset_tag].matches("%#{@search_text}%")
                                 .or(asset_table[:external_id].matches("%#{@search_text}%"))
                                 .or(asset_table[:serial_number].matches("%#{@search_text}%"))
                                 .or(asset_table[:license_plate].matches("%#{@search_text}%")))
    end

    set_var_and_yield_if_present :vehicle_type do
      type_id = FtaSupportVehicleType.find_by(name: @vehicle_type) ||
                FtaVehicleType.find_by(name: @vehicle_type)

      asset_table = Asset.arel_table
      @orphaned_assets = @orphaned_assets
                         .where(asset_table[:fta_support_vehicle_type_id].eq(type_id)
                                 .or(asset_table[:fta_vehicle_type_id].eq(type_id)))
    end
    
    respond_to do |format|
      format.html
      format.json {

        # merge fields
        orphaned_assets_json = @orphaned_assets.order("#{params[:sort]} #{params[:order]}").limit(params[:limit]).offset(params[:offset]).collect{ |p|
          p.as_json.merge!({
             serial_number: p.serial_number,
             license_plane: p.license_plate,
             manufacturer_model: p.manufacturer_model,
             service_status_type: p.service_status_type.try(:to_s),
             vehicle_type: (FtaSupportVehicleType.find_by(id: p.fta_support_vehicle_type_id) || FtaVehicleType.find_by(id: p.fta_vehicle_type_id)).to_s,
             action: new_asset_asset_fleets_path(asset_object_key: p.object_key, format: :js)
         })
        }

        render :json => {
            :total => @orphaned_assets.count,
            :rows =>  orphaned_assets_json
        }
      }
      format.xls
    end
  end

  # GET /asset_fleets/1
  def show
    @category = FtaAssetCategory.asset_types(AssetType.where(class_name:@asset_fleet.asset_fleet_type.class_name)).first
    add_breadcrumb (@category.name == "Equipment") ? "Support Vehicles" : @category.to_s,
                   asset_fleets_path(fta_asset_category_id: @category) if @category
    
    add_breadcrumb @asset_fleet

    builder = AssetFleetBuilder.new(@asset_fleet.asset_fleet_type, @asset_fleet.organization)
    @available_assets = builder.available_assets(builder.asset_group_values({fleet: @asset_fleet}))

  end

  # GET /asset_fleets/new
  def new
    add_breadcrumb 'New'

    @asset_fleet = AssetFleet.new
  end

  # GET /asset_fleets/1/edit
  def edit
    @category = FtaAssetCategory.asset_types(AssetType.where(class_name:@asset_fleet.asset_fleet_type.class_name)).first
    add_breadcrumb (@category.name == "Equipment") ? "Support Vehicles" : @category.to_s,
                   asset_fleets_path(fta_asset_category_id: @category) if @category
    add_breadcrumb @asset_fleet, asset_fleet_path(@asset_fleet)
    add_breadcrumb 'Update'

  end

  # POST /asset_fleets
  def create
    @asset_fleet = AssetFleet.new(asset_fleet_params.except(:assets_attributes))

    @asset_fleet.assets = Asset.where(object_key: params[:asset_object_key])

    @asset_fleet.creator = current_user

    if @asset_fleet.save
      redirect_to @asset_fleet, notice: 'Asset fleet was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /asset_fleets/1
  def update
    if @asset_fleet.update(asset_fleet_params)
      redirect_to asset_fleet_path(@asset_fleet), notice: 'Asset fleet was successfully updated.'
    else
      @category = FtaAssetCategory.asset_types(AssetType.where(class_name:@asset_fleet.asset_fleet_type.class_name)).first
      render :edit
    end
  end

  # DELETE /asset_fleets/1
  def destroy
    @asset_fleet.destroy
    redirect_to asset_fleets_url, notice: 'Asset fleet was successfully destroyed.'
  end

  def builder
    add_breadcrumb "Manage Fleets"

    # Select the fta asset categories that they are allowed to build.
    # This is narrowed down to only asset types they own
    @fta_asset_categories = []
    rev_vehicles = FtaAssetCategory.find_by(name: 'Revenue Vehicles')
    @fta_asset_categories << {id: rev_vehicles.id, label: rev_vehicles.to_s} if Asset.where(organization_id: @organization_list, asset_type: rev_vehicles.asset_types).count > 0
    @fta_asset_categories << {id: FtaAssetCategory.find_by(name: 'Equipment').id, label: 'Support Vehicles'} if SupportVehicle.where(organization_id: @organization_list).count > 0

    @message = "Creating asset fleets. This process might take a while."

    # Pass params through to orphans table
    [:asset_type_id, :search_text, :manufacturer_id, :manufacturer_model, :manufacture_year,
     :asset_subtype_id, :vehicle_type, :service_status_type_id].each do |p|
      instance_variable_set "@#{p}", params[p]
    end
  end

  def runner

    fta_asset_category = FtaAssetCategory.find_by(id: params[:fta_asset_category_id])

    if fta_asset_category.present?
      Delayed::Job.enqueue AssetFleetBuilderJob.new(@organization_list, AssetFleetType.where(class_name: fta_asset_category.asset_types.pluck(:class_name)), FleetBuilderProxy::RESET_ALL_ACTION,current_user), :priority => 0

      # Let the user know the results
      msg = "Fleet Builder is running. You will be notified when the process is complete."
      notify_user(:notice, msg)
    end

    redirect_back(fallback_location: root_path)
  end

  def new_fleet
    asset = Asset.find(params[:asset_id])

    @asset_fleet = AssetFleet.new(organization_id: asset.organization_id, asset_fleet_type: AssetFleetType.find_by(class_name: asset.asset_type.class_name))
    @asset_fleet.assets << asset
    @asset_fleet.creator = current_user
    @asset_fleet.save

    redirect_to asset_fleet_path(@asset_fleet),
                notice: 'Asset fleet was successfully created.'
  end
  
  def new_asset
    asset = Asset.find_by(object_key: params[:asset_object_key])

    unless asset.nil?
      @asset = Asset.get_typed_asset(asset)

      builder = AssetFleetBuilder.new(AssetFleetType.find_by(class_name: @asset.asset_type.class_name), @asset.organization)
      @available_fleets = builder.available_fleets(builder.asset_group_values({asset: @asset}))
    else
      redirect_to builder_asset_fleets_path
    end
  end

  def add_asset

    @asset_fleet = AssetFleet.find_by(id: params[:fleet_asset_builder][:asset_fleet_id])
    @asset = Asset.find_by(id: params[:fleet_asset_builder][:asset_id])

    @asset_fleet.assets << @asset

    redirect_back(fallback_location: root_path)
  end

  def remove_asset
    @asset = Asset.find_by(object_key: params[:asset])

    if @asset.present?
      @asset_fleet.assets.delete @asset
    end

    redirect_back(fallback_location: root_path)
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_asset_fleet
      @asset_fleet = AssetFleet.find_by(object_key: params[:id], organization_id: @organization_list)

      if @asset_fleet.nil?
        if AssetFleet.find_by(object_key: params[:id]).nil?
          redirect_to '/404'
        else
          notify_user(:warning, 'This record is outside your filter. Change your filter if you want to access it.')
          redirect_to asset_fleets_path
        end
        return
      end

    end

  def fleet_asset_builder_params
    params.require(:fleet_asset_builder_proxy).permit(FleetAssetBuilderProxy.allowable_params)
  end

    # Only allow a trusted parameter "white list" through.
    def asset_fleet_params
      params.require(:asset_fleet).permit(AssetFleet.allowable_params)
    end

    def set_form_vars
      @asset_types = AssetType.where(class_name: AssetFleetType.pluck(:class_name))

      @orphaned_assets = Asset
                         .joins('LEFT JOIN assets_asset_fleets ON assets.id = assets_asset_fleets.asset_id')
                         .where(asset_type: @asset_types, organization_id: @organization_list)
                         .where(assets_asset_fleets: {asset_id: nil})

      fta_support_types = FtaSupportVehicleType.where(id: @orphaned_assets.uniq.pluck(:fta_support_vehicle_type_id))
      fta_types = FtaVehicleType.where(id: @orphaned_assets.uniq.pluck(:fta_vehicle_type_id))
      @vehicle_types = [["FTA Support Vehicle Type", fta_support_types], ["FTA Vehicle Type", fta_types]]
      @manufacturers = Manufacturer.where(id: @orphaned_assets.uniq.pluck(:manufacturer_id))
      @manufacturer_models = @orphaned_assets.order(:manufacturer_model).uniq.pluck(:manufacturer_model)
      @asset_subtypes = AssetSubtype.where(id: @orphaned_assets.uniq.pluck(:asset_subtype_id))
    end

    def set_var_and_yield_if_present(param_key)
      instance_variable_set("@#{param_key}", params[param_key])
      yield if params[param_key].present?
    end
end
