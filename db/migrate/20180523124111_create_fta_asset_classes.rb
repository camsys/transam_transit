class CreateFtaAssetClasses < ActiveRecord::Migration[5.2]
  def change
    create_table :fta_asset_classes do |t|
      t.references :fta_asset_category
      t.string :name
      t.string :class_name
      t.boolean :active
    end
  end
end
