class CreateRailSafetyFeatures < ActiveRecord::Migration[5.2]
  def change
    create_table :rail_safety_features do |t|
      t.string :name
      t.string :description
      t.boolean :active
    end

    add_column :ntd_revenue_vehicle_fleets, :total_event_data_recorders, :string, after: :is_autonomous
    add_column :ntd_revenue_vehicle_fleets, :total_emergency_lighting, :string, after: :total_event_data_recorders
    add_column :ntd_revenue_vehicle_fleets, :total_emergency_signage, :string, after: :total_emergency_lighting
    add_column :ntd_revenue_vehicle_fleets, :total_emergency_path_marking, :string, after: :total_emergency_signage

    create_table :assets_rail_safety_features do |t|
      t.integer :transam_asset_id, index: true
      t.integer :rail_safety_feature_id, index: true
    end
  end
end
