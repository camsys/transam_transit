class TamGroupsController < RuleSetAwareController

  before_action :set_tam_policy
  before_action :set_tam_group, only: [:show, :edit, :update, :destroy, :distribute]

  # GET /tam_groups
  def index
    @tam_groups = TamGroup.all
  end

  # GET /tam_groups/1
  def show
  end

  # GET /tam_groups/new
  def new
    @tam_group = TamGroup.new
  end

  # GET /tam_groups/1/edit
  def edit
    render :new, :formats => [:js]
  end

  # POST /tam_groups
  def create
    @tam_group = TamGroup.new(tam_group_params)
    @tam_group.tam_policy = @tam_policy

    if @tam_group.save
      redirect_to rule_set_tam_policies_path(@rule_set_type)
    else
      render :new
    end
  end

  # PATCH/PUT /tam_groups/1
  def update
    if @tam_group.update(tam_group_params)
      redirect_to @tam_group, notice: 'Tam group was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /tam_groups/1
  def destroy
    @tam_group.destroy
    redirect_to tam_groups_url, notice: 'Tam group was successfully destroyed.'
  end

  private
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
