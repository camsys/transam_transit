class AddMultiplePerformanceRestrictionUpdateEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :asset_events, :num_infrastructure, :integer, after: :performance_restriction_type_id
  end
end
