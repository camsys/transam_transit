class UpdateTamPerformanceMetricWithNullUlb < ActiveRecord::DataMigration
  def up
    tam_performance_metrics = TamPerformanceMetric.where(useful_life_benchmark: nil)

    tam_performance_metrics.each { |tpm|
      tpm.useful_life_benchmark = 0;
      tpm.save
    }

  end
end