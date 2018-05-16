class LinkAssetFleetsToNtdReports < ActiveRecord::Migration
  def change
    add_column :ntd_revenue_vehicle_fleets, :vehicle_object_key, :string, after: :ntd_form_id
    add_column :ntd_service_vehicle_fleets, :vehicle_object_key, :string, after: :ntd_form_id
  end
end
