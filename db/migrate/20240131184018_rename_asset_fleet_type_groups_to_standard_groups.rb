class RenameAssetFleetTypeGroupsToStandardGroups < ActiveRecord::Migration[5.2]
  def change
    rename_column :asset_fleet_types, :groups, :standard_groups
  end
end
