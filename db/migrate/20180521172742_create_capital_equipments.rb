class CreateCapitalEquipments < ActiveRecord::Migration[5.2]
  def change
    create_table :capital_equipments do |t|
      t.references :capital_equipmentible, polymorphic: true, index: {name: :capital_equipmentible_idx}
      t.integer :quantity
      t.string :quantity_unit

      t.timestamps
    end
  end
end
