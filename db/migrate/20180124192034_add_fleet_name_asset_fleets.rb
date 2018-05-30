class AddFleetNameAssetFleets < ActiveRecord::Migration
  def change
    add_column :asset_fleets, :fleet_name, :string, after: :agency_fleet_id
  end
end
