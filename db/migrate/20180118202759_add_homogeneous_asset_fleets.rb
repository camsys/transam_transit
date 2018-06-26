class AddHomogeneousAssetFleets < ActiveRecord::Migration[4.2]
  def change
    add_column :asset_fleets, :homogeneous, :boolean, after: :notes
  end
end
