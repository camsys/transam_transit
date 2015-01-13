class CreateLeedCertificationTypes < ActiveRecord::Migration
  def change
    create_table :leed_certification_types do |t|
      t.string :name,      :limit => 64,   :null => false
      t.text :description, :limit => 254,  :null => false
      t.boolean :active,   :null => false
    end

    add_column :assets, :leed_certification_type_id, :integer,   :after => :fta_facility_type_id
  end
end
