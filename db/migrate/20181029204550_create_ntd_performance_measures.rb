class CreateNtdPerformanceMeasures < ActiveRecord::Migration[5.2]
  def change
    create_table :ntd_performance_measures do |t|
      t.references :ntd_report
      t.references :fta_asset_category
      t.string :asset_level
      t.string :pcnt_goal
      t.string :pcnt_performance

      t.timestamps
    end
  end
end
