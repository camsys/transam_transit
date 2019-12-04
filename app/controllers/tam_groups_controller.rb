class TamGroupsController < RuleSetAwareController

  skip_before_action :get_organization_selections
  before_action :set_viewable_organizations

  before_action :set_tam_policy
  before_action :set_tam_group, only: [:edit, :update, :destroy, :distribute, :fire_workflow_event]

  # GET /tam_groups/new
  def new
    @tam_group = TamGroup.new(tam_policy: @tam_policy)

    @asset_categories = Hash.new

    @organization_list.each do |org|
      @asset_categories[org] = TransitAsset.where(organization_id: org).where.not(fta_asset_class: FtaAssetClass.find_by(class_name: 'CapitalEquipment')).pluck(:fta_asset_category_id)
    end

  end

  # GET /tam_groups/1/edit
  def edit
    @asset_categories = Hash.new

    @organization_list.each do |org|
      @asset_categories[org] = TransitAsset.where(organization_id: org).where.not(fta_asset_class: FtaAssetClass.find_by(class_name: 'CapitalEquipment')).pluck(:fta_asset_category_id)
    end

    render :new, :formats => [:js]
  end

  # POST /tam_groups
  def create
    @tam_group = TamGroup.new(tam_group_params.except(:organization_ids))
    @tam_group.tam_policy = @tam_policy

    org_list = tam_group_params[:organization_ids].split(' ').uniq
    org_list.each do |id|
      @tam_group.organizations << Organization.find(id)
    end

    notice = @tam_group.save ? 'TAM group was successfully created.' : 'There was a problem creating the TAM group. Please ensure your name is unique and try again.'
    redirect_to rule_set_tam_policies_path(@rule_set_type), notice: notice
  end

  # PATCH/PUT /tam_groups/1
  def update
    if @tam_group.update(tam_group_params.except(:organization_ids))
      @tam_group.organizations.clear
      # Add the (possibly) new organizations into the object
      tam_group_params[:organization_ids].split(' ').each do |id|
        @tam_group.organizations << Organization.find(id)
      end

      @tam_group.save

      redirect_to rule_set_tam_policies_path(@rule_set_type), notice: 'TAM group was successfully updated.'
    else
      redirect_to rule_set_tam_policies_path(@rule_set_type), notice: 'There was a problem updating the TAM group. Please ensure your name is unique and try again.'
    end


  end

  # DELETE /tam_groups/1
  def destroy
    @tam_group.destroy
    redirect_to rule_set_tam_policies_path(@rule_set_type), notice: 'TAM group was successfully deleted.'
  end

  private

    def set_viewable_organizations
      @viewable_organizations = Organization.ids

      get_organization_selections
    end

    def set_tam_policy
      @tam_policy = TamPolicy.find_by(object_key: params[:tam_policy_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_tam_group
      @tam_group = TamGroup.find_by(object_key: params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def tam_group_params
      params.require(:tam_group).permit(TamGroup.allowable_params)
    end
end
