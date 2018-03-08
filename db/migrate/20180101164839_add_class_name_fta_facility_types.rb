class AddClassNameFtaFacilityTypes < ActiveRecord::Migration
  def change
    add_column :fta_facility_types, :class_name, :string, after: :description
  end
end
