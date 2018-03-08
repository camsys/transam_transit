class CreateFtaPrivateModeTypes < ActiveRecord::Migration
  def change
    create_table :fta_private_mode_types do |t|
      t.string  "name",        :null => false
      t.string  "description", :null => false
      t.boolean "active",      :null => false
    end

    add_reference :assets, :fta_private_mode_type, after: :fta_facility_type_id
  end
end
