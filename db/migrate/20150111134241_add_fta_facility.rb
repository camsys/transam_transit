class AddFtaFacility < ActiveRecord::Migration

  def change
    create_table :fta_facility_types do |t|
      t.string      :name,          :limit => 64,   :null => :false
      t.string      :description,   :limit => 254,  :null => :false
      t.boolean     :active,                        :null => :false
    end
  end

  add_column    :assets, :fta_facility_type_id,     :integer,   :after => :facility_capacity_type_id

end
