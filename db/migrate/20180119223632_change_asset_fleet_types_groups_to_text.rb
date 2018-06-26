class ChangeAssetFleetTypesGroupsToText < ActiveRecord::Migration[4.2]
  def change
    change_column :asset_fleet_types, :groups, :text
  end
end
