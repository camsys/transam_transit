class CreateNtdOrganizationTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :ntd_organization_types do |t|
      t.string :name
      t.boolean :active

      t.timestamps
    end

    add_column :organizations, :ntd_organization_type_id, :integer, after: :fta_agency_type_id
  end
end
