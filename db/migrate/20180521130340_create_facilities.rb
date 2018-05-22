class CreateFacilities < ActiveRecord::Migration[5.2]
  def change
    create_table :facilities do |t|
      t.string :facility_name
      t.string :address1
      t.string :address2
      t.string :city
      t.string :state
      t.string :zip
      t.string :country
      t.references :esl_category
      t.references :facility_categorization
      t.boolean :primary_facility
      t.integer :facility_size
      t.string :facility_size_unit
      t.boolean :section_of_larger_facility
      t.integer :num_structures
      t.integer :num_floors
      t.integer :num_elevators
      t.integer :num_escalators
      t.integer :num_public_parking
      t.integer :num_private_parking
      t.integer :lot_size
      t.string :lot_size_unit
      t.references :leed_certification_type
      t.boolean :ada_accessible
      t.references :fta_private_mode
      t.references :land_owner_organization
      t.string :other_land_owner
      t.references :facility_owner_organization
      t.string :other_facility_owner

      t.timestamps
    end
  end
end
