class RemoveAssetFieldsAssetFleets < ActiveRecord::Migration[4.2]
  def change
    remove_column :asset_fleets, :dedicated
    remove_column :asset_fleets, :has_capital_responsibility
  end
end
