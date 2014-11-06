class AddGoverningBodyToOrganizations < ActiveRecord::Migration
  def change
    change_table :organizations do |t|
      t.string :governing_body, :limit => 128, :after => :fta_service_area_type_id
      t.references :governing_body_type, :after => :governing_body
    end
  end
end
