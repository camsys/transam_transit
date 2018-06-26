class AddCustomGroupsAssetFleetTypes < ActiveRecord::Migration[4.2]
  def change
    add_column :asset_fleet_types, :custom_groups, :text, after: :groups
  end
end
