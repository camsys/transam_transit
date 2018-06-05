class AddClassNameFtaFacilityTypes < ActiveRecord::Migration[4.2]
  def change
    add_column :fta_facility_types, :class_name, :string, after: :description
  end
end
