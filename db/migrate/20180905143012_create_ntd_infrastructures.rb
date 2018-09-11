class CreateNtdInfrastructures < ActiveRecord::Migration[5.2]
  def change
    create_table :ntd_infrastructures do |t|
      t.references :ntd_report
      t.string :fta_mode
      t.string :fta_service_type
      t.string :fta_type
      t.integer :size
      t.integer :linear_miles
      t.integer :track_miles
      t.integer :expected_service_life
      t.integer :pcnt_capital_responsibility
      t.string :shared_capital_responsibility_organization
      t.string :description
      t.string :notes
      t.string :allocation_unit
      t.string :pre_nineteen_thirty
      t.string :nineteen_thirty
      t.string :nineteen_forty
      t.string :nineteen_fifty
      t.string :nineteen_sixty
      t.string :nineteen_seventy
      t.string :nineteen_eighty
      t.string :nineteen_ninety
      t.string :two_thousand
      t.string :two_thousand_ten

      t.timestamps
    end
  end
end
