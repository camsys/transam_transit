class TamPoliciesController < RuleSetAwareController
  layout "tam_policies"

  skip_before_action :get_organization_selections
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
          tam_groups = tam_groups.where('id = ? OR parent_id = ?', @tam_policy_search_proxy.tam_group_id, @tam_policy_search_proxy.tam_group_id)
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
          @tam_metrics = @tam_group.tam_performance_metrics.where(fta_asset_category: @fta_asset_category, asset_level: @fta_asset_category.asset_levels(Asset.where(organization_id: @tam_group.organization_id)))
        else
          @tam_metrics = @tam_group.tam_performance_metrics.where(fta_asset_category: @fta_asset_category)
        end

      end
    end

    puts @tam_policy.inspect
    puts @tam_group.inspect
    puts @fta_asset_category.inspect
    puts @tam_metrics.inspect
  end

  # GET /tam_policies
  # use this page to direct where to go for the first tab
  # driven by role and permissions
  def index
    if can? :update, TamPolicy
      add_breadcrumb 'Group Management', rule_set_tam_policies_path(@rule_set_type)

      # if no param given, default to first policy (most recent)
      if params[:fy_year]
        @tam_policy = TamPolicy.find_by(fy_year: params[:fy_year])
      else
        @tam_policy = TamPolicy.first
      end

    elsif can? :update, TamGroup
      redirect_to tam_groups_rule_set_tam_policies_path(@rule_set_type)
    else
      redirect_to tam_metrics_rule_set_tam_policies_path(@rule_set_type)
    end
  end

  def tam_groups
    add_breadcrumb 'Group Metrics', tam_groups_rule_set_tam_policies_path(@rule_set_type)

    # if no param given, default to first policy (most recent)
    if params[:fy_year]
      @tam_policy = TamPolicy.find_by(fy_year: params[:fy_year])
    else
      @tam_policy = TamPolicy.first
    end

    if @tam_policy
      @tam_groups = @tam_policy.tam_groups.where(organization_id: nil)
      if cannot? :update, TamPolicy # assume can only get to this link if allowed so check if has admin/policy powers or just group lead
        @tam_groups = @tam_groups.where(leader: current_user)
      end

      # if no param given, default to first group of policy
      if params[:tam_group]
        @tam_group = @tam_groups.find_by(object_key: params[:tam_group])
      else
        @tam_group = @tam_groups.first
      end


      if @tam_group
        @fta_asset_category = @tam_group.fta_asset_categories.first
        @tam_metrics = @tam_group.tam_performance_metrics.where(fta_asset_category: @fta_asset_category)
      end
    end
  end

  # main page - most users see this: performance metrics
  def tam_metrics
    add_breadcrumb 'Performance Metrics', tam_metrics_rule_set_tam_policies_path(@rule_set_type)

    # if no param given, default to first policy (most recent)
    if params[:fy_year]
      @tam_policy = TamPolicy.find_by(fy_year: params[:fy_year])
    else
      @tam_policy = TamPolicy.first
    end

    if @tam_policy
      # note that these are the tam groups of the group metric -- theyre not the groups belonging to the org -- for filter form
      @tam_groups = @tam_policy.tam_groups.joins(:organizations).where(organization_id: nil, state: 'distributed').where(tam_groups_organizations: {organization_id: @organization_list}).distinct

      # the tam group detail to show must belong to an org
      # if given tam_group_id use that or default to first tam_group
      # if given organization_id use that or default to first organization of tam_group that belongs to your org list
      if params[:organization]
        org = Organization.find_by(short_name: params[:organization])
        if params[:parent_tam_group] && (@tam_groups.pluck(:object_key).include? params[:parent_tam_group])
          @tam_group = TamGroup.find_by(parent_id: TamGroup.find_by(object_key: params[:parent_tam_group]).id, organization_id: org.id)
        else
          @tam_group = TamGroup.find_by(parent_id: @tam_groups.where(tam_groups_organizations: {organization_id: org.id}).first.id, organization_id: org.id)
        end
      else
        if params[:parent_tam_group] && (@tam_groups.pluck(:object_key).include? params[:parent_tam_group])
          org_list = (TamGroup.find_by(object_key: params[:parent_tam_group]).organization_ids & @organization_list)
          @tam_group = TamGroup.find_by(parent_id: TamGroup.find_by(object_key: params[:parent_tam_group]).id, organization_id: org_list.first)
        else
          org_list = ((@tam_groups.first.try(:organization_ids) || []) & @organization_list)
          @tam_group = TamGroup.find_by(parent: @tam_groups.first, organization_id: org_list.first)
        end
      end

      parent_id = (params[:tam_group_id] || @tam_groups.first.try(:id))
      org_id = (params[:organization_id] || org_list.first)
      if parent_id.present? && org_id.present?
        @tam_group = TamGroup.find_by(parent_id: parent_id, organization_id: org_id)
      end

      if @tam_group
        @fta_asset_category = @tam_group.fta_asset_categories.where(id: FtaAssetCategory.asset_types(AssetType.where(id:Organization.find(@tam_group.organization_id).asset_type_counts.keys)).pluck(:id)).first

        @tam_metrics = @tam_group.tam_performance_metrics.where(fta_asset_category: @fta_asset_category, asset_level: @fta_asset_category.asset_levels(Asset.where(organization_id: @tam_group.organization_id)))
      end
    end
  end


  def get_tam_groups
    fy_year = params[:fy_year]

    groups = TamPolicy.find_by(fy_year: fy_year).tam_groups
    groups = groups.joins(:organizations).where(organization_id: nil).where(tam_groups_organizations: {organization_id: @organization_list}).distinct

    result = groups.pluck(:id, :name)

    respond_to do |format|
      format.json { render json: result.to_json }
    end
  end

  def get_tam_group_organizations
    tam_group_id = params[:tam_group_id]

    group = TamGroup.find_by(id: tam_group_id)

    # you always want the tam group metric not the group tied to the org specifically so if group selected is org-specific get parent
    group = group.parent if group.parent.present?

    result = group.organizations.where(id: @organization_list).map{|org| [org.id, org.coded_name] }

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


    if params[:tam_policy][:copied] == "true"
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
      if can? :update, TamPolicy
        @viewable_organizations = Organization.ids
      elsif can? :update, TamGroup
        @viewable_organizations = (TamGroup.where(leader: current_user).organization_ids + current_user.viewable_organization_ids).uniq
      else
        @viewable_organizations = current_user.viewable_organization_ids
      end

      get_organization_selections
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
