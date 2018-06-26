class AddLabelAssetFleetTypes < ActiveRecord::Migration[4.2]
  def change
    add_column :asset_fleet_types, :label_groups, :string, after: :custom_groups
  end
end
