class CreateFacilityComponentTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :facility_component_types do |t|
      t.string :name
      t.boolean :active
    end
  end
end
