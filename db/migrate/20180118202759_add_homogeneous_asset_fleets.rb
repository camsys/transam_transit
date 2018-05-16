class AddHomogeneousAssetFleets < ActiveRecord::Migration
  def change
    add_column :asset_fleets, :homogeneous, :boolean, after: :notes
  end
end
