class AddAssetsModeServiceJoinTables < ActiveRecord::Migration
  def change
    add_column :assets_fta_mode_types, :id, :primary_key, first: true
    add_column :assets_fta_mode_types, :is_primary, :boolean

    add_column :assets_fta_service_types, :id, :primary_key, first: true
    add_column :assets_fta_service_types, :is_primary, :boolean
  end
end
