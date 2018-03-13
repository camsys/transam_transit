class TamPerformanceMetricsController < ApplicationController

  before_action :set_tam_policy_and_group
  before_action :set_tam_performance_metric, only: [:update]

  # PATCH/PUT /tam_performance_metrics/1
  def update
    respond_to do |format|
      if @tam_performance_metric.update!(tam_performance_metric_params)
        format.json { head :no_content } # 204 No Content
      else
        format.json { render json: @tam_performance_metric.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_all
    respond_to do |format|
      if @tam_group.tam_performance_metrics.where(fta_asset_category_id: params[:fta_asset_category_id]).update_all(tam_performance_metric_params)
        format.json { render json: @tam_group.to_json, status: :ok } # 200 No Content
      else
        format.json { render json: @tam_group.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    def set_tam_policy_and_group
      @tam_policy = TamPolicy.find_by(object_key: params[:tam_policy_id])
      @tam_group = TamGroup.find_by(object_key: params[:tam_group_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_tam_performance_metric
      @tam_performance_metric = TamPerformanceMetric.find_by(object_key: params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def tam_performance_metric_params
      params.require(:tam_performance_metric).permit(TamPerformanceMetric.allowable_params)
    end
end
