class CreateFacilityComponents < ActiveRecord::Migration[5.2]
  def change
    create_table :facility_components do |t|
      t.references :facility_component_type

      t.timestamps
    end
  end
end
