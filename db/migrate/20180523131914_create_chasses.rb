class CreateChasses < ActiveRecord::Migration[5.2]
  def change
    create_table :chasses do |t|
      t.string :name
      t.boolean :active
    end
  end
end
