class CreateAssetFleetTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :asset_fleet_types do |t|
      t.string :class_name
      t.string :groups
      t.boolean :active
    end
  end
end
