class AddFleetNameAssetFleets < ActiveRecord::Migration[4.2]
  def change
    add_column :asset_fleets, :fleet_name, :string, after: :agency_fleet_id
  end
end
