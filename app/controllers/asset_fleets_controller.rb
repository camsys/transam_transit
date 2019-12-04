class AssetFleetsController < OrganizationAwareController

  layout 'asset_fleets'

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Fleets", :asset_fleets_path

  before_action :set_asset_fleet, only: [:show, :edit, :update, :destroy, :remove_asset, :render_mileage_table]

  before_action :set_form_vars, only: [:orphaned_assets, :builder]
  
  # GET /asset_fleets
  def index
    params[:sort] ||= 'ntd_id'

    @fta_asset_category = (FtaAssetCategory.find_by(id: params[:fta_asset_category_id]) || FtaAssetCategory.first)
    @asset_fleet_types = AssetFleetType.where(class_name: @fta_asset_category.fta_asset_classes.distinct.pluck(:class_name))
    # Go ahead and join with assets since almost every query requires it
    @asset_fleets = AssetFleet.where(organization_id: @organization_list, asset_fleet_type_id: @asset_fleet_types.pluck(:id)).distinct
                        .joins(:assets)
                        .joins("INNER JOIN `transit_assets` ON `transit_assets`.`transit_assetible_id` = `service_vehicles`.`id` AND `transit_assets`.`transit_assetible_type` = 'ServiceVehicle'")
                        .joins("INNER JOIN `transam_assets` ON `transam_assets`.`transam_assetible_id` = `transit_assets`.`id` AND `transam_assets`.`transam_assetible_type` = 'TransitAsset'")



    case @fta_asset_category.name
    when "Equipment"
      crumb = "Service Vehicles (Non-Revenue)"
      @text_search_prompt = 'NTD ID/Agency Fleet ID/Fleet Name'
      include_fleet_name = true
      @vehicle_types = FtaSupportVehicleType.active
      # Disallow/map certain sort parameters
      case params[:sort]
      when 'primary_fta_service_type_id', 'active_count'
        params[:sort] = 'ntd_id'
      when 'fta_vehicle_type_id'
        params[:sort] = 'fta_support_vehicle_type_id'
      end
    else # Primarily Revenue vehicles for now
      crumb =  @fta_asset_category.to_s
      @text_search_prompt = 'NTD ID'
      include_fleet_name = false
      @service_types = FtaServiceType.active.all
      @vehicle_types = FtaVehicleType.active
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
                      .joins("INNER JOIN assets_fta_mode_types ON assets_fta_mode_types.transam_asset_type = 'ServiceVehicle' AND service_vehicles.id = assets_fta_mode_types.transam_asset_id")
                      .where(assets_fta_mode_types: {is_primary: true})

    when 'primary_fta_service_type_id'
      params[:sort] = 'assets_fta_service_types.fta_service_type_id'
      @asset_fleets = @asset_fleets
                      .joins("INNER JOIN assets_fta_service_types ON assets_fta_service_types.transam_asset_type = 'RevenueVehicle' AND transam_assets.id = assets_fta_service_types.transam_asset_id")
                      .where(assets_fta_service_types: {is_primary: true})
    else
      # Asset field
      if TransamAsset.column_names.include? params[:sort]
        params[:sort] = "transam_assets.#{params[:sort]}"
      else
        params[:sort] = "transit_assets.#{params[:sort]}"
      end
    end
    
    add_breadcrumb crumb

    # Set up filter collections
    @primary_modes = FtaModeType.where(id: AssetsFtaModeType.joins(:fta_mode_type)
                                        .where(assets_fta_mode_types: {is_primary: true, transam_asset_id: @asset_fleets.pluck('assets_asset_fleets.transam_asset_id'), transam_asset_type: 'ServiceVehicle'})
                                       .distinct.pluck(:fta_mode_type_id))
    # only load Vehicle manufacturers because rails cars and locomotives have the same ones
    @manufacturers = Manufacturer.where(filter: @fta_asset_category.name == 'Equipment' ? ['SupportVehicle'] : ['Vehicle'])
    
    # Filter results
    # Primary FTA Mode Type is particularly messy
    set_var_and_yield_if_present :primary_fta_mode_type_id do
      @asset_fleets = @asset_fleets
                      .joins("INNER JOIN assets_fta_mode_types ON transam_asset_type = 'ServiceVehicle' AND transam_assets.id = assets_fta_mode_types.transam_asset_id")
                      .where(assets_fta_mode_types: {fta_mode_type_id: @primary_fta_mode_type_id,
                                                     is_primary: true})
    end

    # As is Primary FTA Service Type
    set_var_and_yield_if_present :primary_fta_service_type_id do
      @asset_fleets = @asset_fleets
                      .joins("INNER JOIN assets_fta_service_types ON transam_asset_type = 'RevenueVehicle' AND transam_assets.id = assets_fta_service_types.transam_asset_id")
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
      @asset_fleets = @asset_fleets.where(transit_assets: {fta_type_id: @fta_vehicle_type_id})

    end
    
    set_var_and_yield_if_present :manufacturer_id do
      # if vehicle manufacturer need to also pull same rail car/locomotive manufacturer
      manufacturer = Manufacturer.find_by(id: @manufacturer_id)
      @asset_fleets = @asset_fleets.where(transam_assets: {manufacturer_id: Manufacturer.where(code: manufacturer.code, filter: manufacturer.filter == 'SupportVehicle' ? ['SupportVehicle'] : ['Vehicle', 'RailCar', 'Locomotive']).pluck(:id)})
    end

    set_var_and_yield_if_present :manufacture_year do
      @asset_fleets = @asset_fleets.where(transam_assets: {manufacture_year: @manufacture_year})
    end

    @status = params[:status] || 'Active'
    if @status == 'Active'
      @asset_fleets = @asset_fleets.where(transam_assets: {disposition_date: nil}, service_vehicles: {fta_emergency_contingency_fleet: false})
    else
      @asset_fleets = @asset_fleets
                      .where.not(id: @asset_fleets.where(transam_assets: {disposition_date: nil}, service_vehicles: {fta_emergency_contingency_fleet: false}).pluck(:id))
    end
    
    respond_to do |format|
      format.html 
      format.json {
        asset_fleet_josn = @asset_fleets.order("#{params[:sort]} #{params[:order]}").limit(params[:limit]).offset(params[:offset]).collect{ |p|
          manufacturer_model = p.get_manufacturer_model.try(:name) 
          if manufacturer_model == "Other"
            manufacturer_model = p.get_other_manufacturer_model
          end
   
          p.as_json.merge!({
            manufacturer_model: manufacturer_model
         })
        }

        render :json => {
            :total => @asset_fleets.count,
            :rows =>  asset_fleet_josn
        }
      }
      format.xls
    end
  end

  def orphaned_assets
    # check that an order param was provided otherwise use asset_tag as the default
    params[:sort] ||= 'asset_tag'

    [:fta_asset_class_id, :manufacturer_id, :manufacturer_model, :manufacture_year,
     :asset_subtype_id, :vehicle_type, :service_status_type_id].each do |p|
      set_var_and_yield_if_present p do
        @orphaned_assets = @orphaned_assets.where(p => params[p])
      end
    end

    set_var_and_yield_if_present :search_text do
      asset_table = TransamAsset.arel_table

      @orphaned_assets = @orphaned_assets
                         .where(asset_table[:asset_tag].matches("%#{@search_text}%")
                                 .or(asset_table[:external_id].matches("%#{@search_text}%"))
                                 .or(asset_table[:serial_number].matches("%#{@search_text}%"))
                                 .or(ServiceVehicle.arel_table[:license_plate].matches("%#{@search_text}%")))
    end

    set_var_and_yield_if_present :vehicle_type do
      type_id = FtaSupportVehicleType.find_by(name: @vehicle_type) ||
                FtaVehicleType.find_by(name: @vehicle_type)

      asset_table = TransitAsset.arel_table
      @orphaned_assets = @orphaned_assets
                         .where(asset_table[:fta_type_id].eq(type_id)
                                 .or(asset_table[:fta_type_id].eq(type_id)))
    end
    
    respond_to do |format|
      format.html
      format.json {

        # merge fields
        orphaned_assets_json = @orphaned_assets.order("#{params[:sort]} #{params[:order]}").limit(params[:limit]).offset(params[:offset]).collect{ |p|
          manufacturer_model = p.manufacturer_model.try(:name) 
          if manufacturer_model == "Other"
            manufacturer_model = p.other_manufacturer_model
          end
          asset_type = p.asset_type.try(:to_s)
          if asset_type == "Support Vehicles"
            asset_type = p.fta_asset_class.name
          end
   
          p.as_json.merge!({
            organization_short_name: p.organization.short_name,
            asset_type: asset_type,
            asset_subtype: p.asset_subtype.try(:to_s),
             serial_number: p.serial_number,
             license_plane: p.license_plate,
             manufacturer_model: manufacturer_model,
             manufacturer: p.manufacturer.try(:code),
             service_status_type: p.service_status_type.try(:to_s),
             vehicle_type: p.fta_type.to_s,
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
    @category = FtaAssetClass.find_by(class_name:@asset_fleet.asset_fleet_type.class_name).fta_asset_category
    add_breadcrumb (@category.name == "Equipment") ? "Service Vehicles (Non-Revenue)" : @category.to_s,
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
    @category = FtaAssetClass.find_by(class_name:@asset_fleet.asset_fleet_type.class_name).fta_asset_category
    add_breadcrumb (@category.name == "Equipment") ? "Service Vehicles (Non-Revenue)" : @category.to_s,
                   asset_fleets_path(fta_asset_category_id: @category) if @category
    add_breadcrumb @asset_fleet, asset_fleet_path(@asset_fleet)
    add_breadcrumb 'Update'

  end

  # POST /asset_fleets
  def create
    @asset_fleet = AssetFleet.new(asset_fleet_params.except(:assets_attributes))

    @asset_fleet.assets = ServiceVehicle.where(object_key: params[:asset_object_key])

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
      @category = FtaAssetClass.find_by(class_name:@asset_fleet.asset_fleet_type.class_name).fta_asset_category
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
    @fta_asset_categories << {id: rev_vehicles.id, label: rev_vehicles.to_s.singularize} if RevenueVehicle.where(organization_id: @organization_list).count > 0 && !@running_jobs.include?("RevenueVehicle")
    @fta_asset_categories << {id: FtaAssetCategory.find_by(name: 'Equipment').id, label: 'Service Vehicle (Non-Revenue)'} if ServiceVehicle.where(organization_id: @organization_list, service_vehiclible_type: nil).count > 0 && !@running_jobs.include?("ServiceVehicle")

    @message = "Creating asset fleets. This process might take a while."

    # Pass params through to orphans table
    [:fta_asset_class_id, :search_text, :manufacturer_id, :manufacturer_model, :manufacture_year,
     :asset_subtype_id, :vehicle_type, :service_status_type_id].each do |p|
      instance_variable_set "@#{p}", params[p]
    end
  end

  def runner

    fta_asset_category = FtaAssetCategory.find_by(id: params[:fta_asset_category_id])

    if fta_asset_category.present?
      Delayed::Job.enqueue AssetFleetBuilderJob.new(@organization_list, AssetFleetType.where(class_name: fta_asset_category.fta_asset_classes.distinct.pluck(:class_name)), FleetBuilderProxy::RESET_ALL_ACTION,current_user), :priority => 0

      # Let the user know the results
      msg = "Fleet Builder is running. You will be notified when the process is complete."
      notify_user(:notice, msg)
    end

    redirect_back(fallback_location: root_path)
  end

  def new_fleet
    asset = ServiceVehicle.find_by(object_key: params[:asset_id])

    @asset_fleet = AssetFleet.new(organization_id: asset.organization_id, asset_fleet_type: AssetFleetType.find_by(class_name: asset.fta_asset_class.class_name))
    @asset_fleet.assets << asset
    @asset_fleet.creator = current_user
    @asset_fleet.save

    redirect_to asset_fleet_path(@asset_fleet),
                notice: 'Asset fleet was successfully created.'
  end
  
  def new_asset
    asset = TransamAsset.find_by(object_key: params[:asset_object_key])

    unless asset.nil?
      @asset = asset.very_specific

      builder = AssetFleetBuilder.new(AssetFleetType.find_by(class_name: @asset.fta_asset_class.class_name), @asset.organization)
      @available_fleets = builder.available_fleets(builder.asset_group_values({asset: @asset}))
    else
      redirect_to builder_asset_fleets_path
    end
  end

  def add_asset

    @asset_fleet = AssetFleet.find_by(id: params[:fleet_asset_builder][:asset_fleet_id])
    @asset = ServiceVehicle.find_by(object_key: params[:fleet_asset_builder][:asset_id])

    @asset_fleet.assets << @asset

    redirect_back(fallback_location: root_path)
  end

  def remove_asset
    @asset = ServiceVehicle.find_by(object_key: params[:asset])

    if @asset.present?
      @asset_fleet.assets.delete @asset
    end

    redirect_back(fallback_location: root_path)
  end

  def render_mileage_table
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
      @running_jobs = []
      ["RevenueVehicle", "ServiceVehicle"].each do |t|
        if Delayed::Job.exists?(["handler like ? and handler like ?", "%AssetFleetBuilderJob%", "%#{t}%"])
          @running_jobs << t
        end
      end

      @fta_asset_classes = FtaAssetClass.where(class_name: AssetFleetType.where.not(class_name: @running_jobs).pluck(:class_name))

      @orphaned_assets = ServiceVehicle
                             .joins(transit_asset: [transam_asset: [:organization, asset_subtype: :asset_type]])
                             .left_outer_joins(:asset_fleets)
                             .where(organization_id: @organization_list, fta_asset_class: @fta_asset_classes)
                             .where(assets_asset_fleets: {transam_asset_id: nil})

      fta_support_types = FtaSupportVehicleType.where(id: @orphaned_assets.distinct.pluck(:fta_type_id))
      fta_types = FtaVehicleType.where(id: @orphaned_assets.distinct.pluck(:fta_type_id))
      @vehicle_types = [["Equipment : Service Vehicles (Non-Revenue)", fta_support_types], ["Revenue Vehicles : All Classes", fta_types]]
      @manufacturers = Manufacturer.where(id: @orphaned_assets.distinct.pluck(:manufacturer_id))
      @manufacturer_models = ManufacturerModel.where(id: @orphaned_assets.distinct.pluck(:manufacturer_model_id))
      @asset_subtypes = AssetSubtype.where(id: @orphaned_assets.distinct.pluck(:asset_subtype_id))
    end

    def set_var_and_yield_if_present(param_key)
      instance_variable_set("@#{param_key}", params[param_key])
      yield if params[param_key].present?
    end
end
