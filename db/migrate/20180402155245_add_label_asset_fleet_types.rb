class AddLabelAssetFleetTypes < ActiveRecord::Migration
  def change
    add_column :asset_fleet_types, :label_groups, :string, after: :custom_groups
  end
end
