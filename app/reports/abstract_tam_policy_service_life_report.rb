class AbstractTamPolicyServiceLifeReport < AbstractReport

  include FiscalYear
  include TransamFormatHelper

  def initialize(attributes = {})
    super(attributes)
  end

  def self.get_underlying_date

  end

  def get_data

  end

  def grouped_activated_tam_performance_metrics(organization_id_list, fta_asset_category)
    result = Hash.new

    if TamPolicy.first
      metrics = TamPolicy.first.tam_performance_metrics
                    .joins(tam_group: :organization)
                    .where(tam_groups: {state: ['pending_activation','activated'], organization_id: organization_id_list})
                    .where(asset_level: fta_asset_category.asset_levels)

      if fta_asset_category.name == 'Revenue Vehicles'
        metrics = metrics.joins('INNER JOIN fta_vehicle_types AS asset_levels_table ON asset_levels_table.id = tam_performance_metrics.asset_level_id AND tam_performance_metrics.asset_level = "FtaVehicleType"')
      elsif fta_asset_category.name == 'Equipment'
        metrics = metrics.joins('INNER JOIN fta_support_vehicle_types AS asset_levels_table ON asset_levels_table.id = tam_performance_metrics.asset_level_id AND tam_performance_metrics.asset_level = "FtaSupportVehicleType"')
      elsif fta_asset_category.name == 'Facilities'
        metrics = metrics.joins('INNER JOIN fta_asset_classes AS asset_levels_table ON asset_levels_table.id = tam_performance_metrics.asset_level_id AND tam_performance_metrics.asset_level = "FtaAssetClass"')
      else
        metrics = metrics.joins('INNER JOIN fta_mode_types AS asset_levels_table ON asset_levels_table.id = tam_performance_metrics.asset_level_id AND tam_performance_metrics.asset_level = "FtaModeType"')
      end


      metrics.pluck('organizations.short_name', 'asset_levels_table.name', :useful_life_benchmark, :goal_pcnt).each do |metric|
        result[metric[0..1]] = metric[2..-1]
      end
    end

    result
  end
end