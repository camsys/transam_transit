class AddAssetLevelTamPerformanceMetrics < ActiveRecord::Migration
  def change
    change_table :tam_performance_metrics do |t|
      t.references :asset_level, :polymorphic => true, :after => :fta_asset_category_id
    end
  end
end
