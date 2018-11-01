class FixFtaEquipmentTypeActiveBoolean < ActiveRecord::Migration[5.2]
  def change
    change_column :fta_equipment_types, :active, :boolean
  end
end
