class CleanupOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :service_area_population, :integer, after: :fta_service_area_type_id
    add_column :organizations, :service_area_size, :integer, after: :service_area_population
    add_column :organizations, :service_area_size_unit, :string, after: :service_area_size
  end
end
