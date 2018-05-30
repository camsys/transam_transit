class CreateAssetFleetTypes < ActiveRecord::Migration
  def change
    create_table :asset_fleet_types do |t|
      t.string :class_name
      t.string :groups
      t.boolean :active
    end
  end
end
