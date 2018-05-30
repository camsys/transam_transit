class CreateAssetFleets < ActiveRecord::Migration
  def change
    create_table :asset_fleets do |t|
      t.string :object_key, index: true
      t.references :organization, index: true
      t.references :asset_fleet_type
      t.string :agency_fleet_id
      t.integer :ntd_id
      t.boolean :dedicated
      t.boolean :has_capital_responsibility
      t.boolean :active

      t.timestamps
    end

    create_table :assets_asset_fleets, id: false do |t|
      t.belongs_to :asset, index: true
      t.belongs_to :asset_fleet, index: true
    end
  end
end
