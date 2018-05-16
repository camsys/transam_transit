class ChangeAssetFleetTypesGroupsToText < ActiveRecord::Migration
  def change
    change_column :asset_fleet_types, :groups, :text
  end
end
