class AddFtaEmergencyContingencyFleetAssetEvent < ActiveRecord::Migration[5.2]
  def change
    add_column :service_vehicles, :fta_emergency_contingency_fleet, :boolean, after: :serial_number
    add_column :asset_events, :fta_emergency_contingency_fleet, :boolean, after: :service_status_type_id
  end
end
