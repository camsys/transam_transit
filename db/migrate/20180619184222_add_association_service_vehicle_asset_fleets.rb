class AddAssociationServiceVehicleAssetFleets < ActiveRecord::Migration[5.2]
  def change
    add_column :assets_asset_fleets, :service_vehicle_id, :integer, after: :asset_id
  end
end
