class RemoveAssetFieldsAssetFleets < ActiveRecord::Migration
  def change
    remove_column :asset_fleets, :dedicated
    remove_column :asset_fleets, :has_capital_responsibility
  end
end
