class CreateGoverningBodyTypes < ActiveRecord::Migration
  def change
    create_table :governing_body_types do |t|
      t.string  "name",        limit: 64,  null: false
      t.string  "code",        limit: 2,   null: false
      t.string  "description", limit: 254, null: false
      t.boolean "active",                  null: false
      
    end
  end
end
