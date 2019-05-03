class AddGroupMeasureNtdPerformanceMeasures < ActiveRecord::Migration[5.2]
  def change
    add_column :ntd_performance_measures, :is_group_measure, :boolean, after: :future_pcnt_goal
  end
end
