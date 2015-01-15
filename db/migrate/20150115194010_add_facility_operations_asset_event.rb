class AddFacilityOperationsAssetEvent < ActiveRecord::Migration
  def change
    add_column :asset_events, :annual_affected_ridership, :integer, :after => :actual_costs
    add_column :asset_events, :annual_dollars_generated, :integer, :after => :annual_affected_ridership
  end
end
