class TamPoliciesController < ApplicationController
  before_action :set_tam_policy, only: [:show, :edit, :update, :destroy]

  # GET /tam_policies
  def index
    @tam_policies = TamPolicy.all
  end

  # GET /tam_policies/1
  def show
  end

  # GET /tam_policies/new
  def new
    @tam_policy = TamPolicy.new
  end

  # GET /tam_policies/1/edit
  def edit
  end

  # POST /tam_policies
  def create
    @tam_policy = TamPolicy.new(tam_policy_params)

    if @tam_policy.save
      redirect_to @tam_policy, notice: 'Tam policy was successfully created.'
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
    # Use callbacks to share common setup or constraints between actions.
    def set_tam_policy
      @tam_policy = TamPolicy.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def tam_policy_params
      params[:tam_policy]
    end
end
