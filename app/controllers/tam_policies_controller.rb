class TamPoliciesController < RuleSetAwareController
  layout "tam_policies"

  before_action :set_viewable_organizations

  before_action :set_tam_policy, only: [:edit, :update, :destroy, :new_tam_group]

  def search
    @tam_policy_search_proxy = TamPolicySearchProxy.new(tam_policy_search_params)

    @tam_policy = TamPolicy.find_by(fy_year: @tam_policy_search_proxy.fy_year)
    if @tam_policy

      if @tam_policy_search_proxy.organization_id.present? || @tam_policy_search_proxy.tam_group_id.present?
        tam_groups = @tam_policy.tam_groups
        if @tam_policy_search_proxy.organization_id.present?
          tam_groups = tam_groups.where(organization_id: @tam_policy_search_proxy.organization_id)
        end
        if @tam_policy_search_proxy.tam_group_id.present?
          tam_groups = tam_groups.where(id: @tam_policy_search_proxy.tam_group_id)
        end
        @tam_group = tam_groups.first
      end

      if @tam_group
        if @tam_policy_search_proxy.fta_asset_category_id.present?
          @fta_asset_category = @tam_group.fta_asset_categories.find_by(id: @tam_policy_search_proxy.fta_asset_category_id)
        else
          if @tam_policy_search_proxy.organization_id.present?
            @fta_asset_category = @tam_group.fta_asset_categories.where(id: FtaAssetCategory.asset_types(AssetType.where(id:Organization.find_by(id: @tam_policy_search_proxy.organization_id).asset_type_counts.keys)).pluck(:id)).first
          else
            @fta_asset_category = @tam_group.fta_asset_categories.first
          end
        end

        if @tam_group.organization_id.present?
          @tam_metrics = @tam_group.tam_performance_metrics.where(fta_asset_category: @fta_asset_category, asset_level: @fta_asset_category.class_or_types.where(id: Asset.where(organization_id: @tam_group.organization_id).distinct.pluck("#{@fta_asset_category.class_or_types.name.underscore}_id")))
        else
          @tam_metrics = @tam_group.tam_performance_metrics.where(fta_asset_category: @fta_asset_category)
        end


      end
    end
  end

  # GET /tam_policies
  # use this page to direct where to go for the first tab
  # driven by role and permissions
  def index
    if can? :update, TamPolicy
      add_breadcrumb 'Group Management', rule_set_tam_policies_path(@rule_set_type)

      @tam_policy = TamPolicy.first
    elsif can? :update, TamGroup
      redirect_to tam_groups_rule_set_tam_policies_path(@rule_set_type)
    else
      redirect_to tam_metrics_rule_set_tam_policies_path(@rule_set_type)
    end
  end

  def tam_groups
    add_breadcrumb 'Group Metrics', tam_groups_rule_set_tam_policies_path(@rule_set_type)

    @tam_policy = TamPolicy.first
    tam_groups = @tam_policy.tam_groups.where(organization_id: nil)
    if cannot? :update, TamPolicy # assume can only get to this link if allowed so check if has admin/policy powers or just group lead
      tam_groups = tam_groups.where(leader: current_user)
    end
    @tam_group = tam_groups.first
    if @tam_group
      @fta_asset_category = @tam_group.fta_asset_categories.first
      @tam_metrics = @tam_group.tam_performance_metrics.where(fta_asset_category: @fta_asset_category)
    end
  end

  # main page - most users see this: performance metrics
  def tam_metrics
    add_breadcrumb 'Performance Metrics', tam_metrics_rule_set_tam_policies_path(@rule_set_type)

    @tam_policy = TamPolicy.first
    @tam_group = @tam_policy.tam_groups.with_state(:pending_activation, :activated).find_by(organization_id: @organization_list.first)
    if @tam_group
      @fta_asset_category = @tam_group.fta_asset_categories.where(id: FtaAssetCategory.asset_types(AssetType.where(id:Organization.find(@organization_list.first).asset_type_counts.keys)).pluck(:id)).first

      if @tam_group.organization_id.present?

        @tam_metrics = @tam_group.tam_performance_metrics.where(fta_asset_category: @fta_asset_category, asset_level: @fta_asset_category.class_or_types.where(id: Asset.where(organization_id: @tam_group.organization_id).distinct.pluck("#{@fta_asset_category.class_or_types.name.underscore}_id")))
      else
        @tam_metrics = @tam_group.tam_performance_metrics.where(fta_asset_category: @fta_asset_category)
      end

    end
  end


  def get_tam_groups
    fy_year = params[:fy_year]

    result = TamGroup.where(tam_policy: TamPolicy.find_by(fy_year: fy_year)).pluck(:id, :name)

    respond_to do |format|
      format.json { render json: result.to_json }
    end
  end

  # GET /tam_policies/new
  # group management tab
  def new
  end

  # GET /tam_policies/1/edit
  def edit
  end

  # POST /tam_policies
  def create


    if params[:tam_policy][:copied]
      puts "copying"
      @tam_policy = TamPolicy.first
      copy
      @new_tam_policy.fy_year += 1

      @tam_policy = @new_tam_policy
    else
      @tam_policy = TamPolicy.new(tam_policy_params)
    end

    if @tam_policy.save
      redirect_to rule_set_tam_policies_path(@rule_set_type)
    else
      render :new
    end
  end

  # PATCH/PUT /tam_policies/1
  def update
    if @tam_policy.update(tam_policy_params)
      redirect_to @tam_policy, notice: 'Tam policy was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /tam_policies/1
  def destroy
    @tam_policy.destroy
    redirect_to tam_policies_url, notice: 'Tam policy was successfully destroyed.'
  end



  private



    def set_viewable_organizations
      @viewable_organizations = current_user.viewable_organizations
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_tam_policy
      @tam_policy = TamPolicy.find_by(object_key: params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def tam_policy_params
      params.require(:tam_policy).permit(TamPolicy.allowable_params)
    end

    def tam_policy_search_params
      params.require(:tam_policy_search_proxy).permit(TamPolicySearchProxy.allowable_params)
    end
end
