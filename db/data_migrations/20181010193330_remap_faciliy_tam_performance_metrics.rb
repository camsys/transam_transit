class RemapFaciliyTamPerformanceMetrics < ActiveRecord::DataMigration
  def up
    TamGroup.joins(:fta_asset_categories).where(fta_asset_categories: {name: 'Facilities'}).each do |group|
      FtaAssetClass.all.each do |fta_asset_class|
        old_metrics = group.tam_performance_metrics.where(asset_level: FtaFacilityType.where(fta_asset_class: fta_asset_class))
        if old_metrics.count > 0
          new_metric = old_metrics.first
          if old_metrics.distinct.pluck(:useful_life_benchmark, :goal_pcnt).count == 1
            new_metric.update(asset_level: fta_asset_class)
          else
            puts "Tam Group #{group}: #{fta_asset_class} defaulted to 3.0 TERM and max goal pcnt"
            new_metric.update(asset_level: fta_asset_class, useful_life_benchmark: 3, goal_pcnt: old_metrics.maximum(:goal_pcnt))
          end
          old_metrics.where.not(object_key: new_metric.object_key).delete_all
        end
      end
    end
  end
end