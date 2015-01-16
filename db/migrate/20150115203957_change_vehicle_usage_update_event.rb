class ChangeVehicleUsageUpdateEvent < ActiveRecord::Migration
  def change
    rename_column :asset_events, :avg_daily_use, :avg_daily_use_hours
    add_column :asset_events, :avg_daily_use_miles, :integer, :after => :avg_daily_use_hours

  end
end
