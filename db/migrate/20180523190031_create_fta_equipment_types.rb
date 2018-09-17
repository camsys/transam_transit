class CreateFtaEquipmentTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :fta_equipment_types do |t|
      t.references :fta_asset_class
      t.string :name
      t.string :active
    end
  end
end
