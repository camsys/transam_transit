class AddFuturePcntGoalNtdPerformanceMeasures < ActiveRecord::Migration[5.2]
  def change
    add_column :ntd_performance_measures, :future_pcnt_goal, :integer, after: :pcnt_performance
  end
end
