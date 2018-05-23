class CreateFacilityComponents < ActiveRecord::Migration[5.2]
  def change
    create_table :facility_components do |t|
      t.references :facility_component_categorization
      t.references :facility_component_type
      t.string :facility_name

      t.timestamps
    end
  end
end
