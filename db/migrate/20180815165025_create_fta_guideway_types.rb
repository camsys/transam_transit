class CreateFtaGuidewayTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :fta_guideway_types do |t|
      t.string :name
      t.boolean :active
    end
  end
end
