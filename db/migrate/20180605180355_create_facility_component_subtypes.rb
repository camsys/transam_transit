class CreateFacilityComponentSubtypes < ActiveRecord::Migration[5.2]
  def change
    create_table :facility_component_subtypes do |t|
      t.string :name
      t.boolean :active

      t.timestamps
    end
  end
end
