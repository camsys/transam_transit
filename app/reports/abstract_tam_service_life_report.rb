class AbstractTamServiceLifeReport < AbstractReport

  include FiscalYear
  include TransamFormatHelper

  def initialize(attributes = {})
    super(attributes)
  end

  def self.get_underlying_date

  end

  def get_data

  end

  def grouped_activated_tam_performance_metrics(organization_id_list, fta_asset_category, single_org_view, asset_counts)
    result = Hash.new

    if TamPolicy.first
      metrics = TamPerformanceMetric
                    .joins(tam_group: [:tam_policy, :organization])
                    .joins("INNER JOIN (SELECT tam_groups.organization_id, MAX(tam_policies.fy_year) AS max_fy_year FROM tam_groups INNER JOIN tam_policies ON tam_policies.id = tam_groups.tam_policy_id WHERE tam_groups.state IN ('activated') GROUP BY tam_groups.organization_id) AS max_tam_policy ON max_tam_policy.organization_id = tam_groups.organization_id AND max_tam_policy.max_fy_year = tam_policies_tam_groups.fy_year")
                    .where(tam_groups: {state: ['pending_activation','activated'], organization_id: organization_id_list})
                    .where(asset_level: fta_asset_category.asset_levels)

      if fta_asset_category.name == 'Revenue Vehicles'
        metrics = metrics.joins('INNER JOIN fta_vehicle_types AS asset_levels_table ON asset_levels_table.id = tam_performance_metrics.asset_level_id AND tam_performance_metrics.asset_level_type = "FtaVehicleType"')
      elsif fta_asset_category.name == 'Equipment'
        metrics = metrics.joins('INNER JOIN fta_support_vehicle_types AS asset_levels_table ON asset_levels_table.id = tam_performance_metrics.asset_level_id AND tam_performance_metrics.asset_level_type = "FtaSupportVehicleType"')
      elsif fta_asset_category.name == 'Facilities'
        metrics = metrics.joins('INNER JOIN fta_asset_classes AS asset_levels_table ON asset_levels_table.id = tam_performance_metrics.asset_level_id AND tam_performance_metrics.asset_level_type = "FtaAssetClass"')
      else
        metrics = metrics.joins('INNER JOIN fta_mode_types AS asset_levels_table ON asset_levels_table.id = tam_performance_metrics.asset_level_id AND tam_performance_metrics.asset_level_type = "FtaModeType"')
      end

      sum_ulb_goal_per_asset = Hash.new
      count_asset_with_ulb = Hash.new

      tam_policy_fy_year = nil

      metrics.pluck('organizations.short_name', fta_asset_category.name == 'Revenue Vehicles' ? 'CONCAT(asset_levels_table.code," - " ,asset_levels_table.name)' : 'asset_levels_table.name', 'max_fy_year', :useful_life_benchmark, :pcnt_goal).each_with_index do |metric, idx|
        if single_org_view
          result[metric[0..1]] = metric[2..4]
        else
          if idx == 0
            tam_policy_fy_year = metric[2]
          elsif metric[2] != tam_policy_fy_year
            tam_policy_fy_year = 'Multiple'
          end

          if sum_ulb_goal_per_asset[metric[1]].nil?
            if asset_counts[metric[0..1]]
              sum_ulb_goal_per_asset[metric[1]] = [metric[3]*asset_counts[metric[0..1]], metric[4]*asset_counts[metric[0..1]]]
              count_asset_with_ulb[metric[1]] = asset_counts[metric[0..1]]
            end
          else
            if asset_counts[metric[0..1]]
              sum_ulb_goal_per_asset[metric[1]][0] += metric[3]*asset_counts[metric[0..1]]
              sum_ulb_goal_per_asset[metric[1]][1] += metric[4]*asset_counts[metric[0..1]]
              count_asset_with_ulb[metric[1]] += asset_counts[metric[0..1]]
            end
          end
        end
      end



      unless single_org_view
        sum_ulb_goal_per_asset.each do |k, v|
          result[k] = [tam_policy_fy_year, (v[0] / count_asset_with_ulb[k].to_f), (v[1] / count_asset_with_ulb[k].to_f)]
        end
      end
    end

    result
  end
end