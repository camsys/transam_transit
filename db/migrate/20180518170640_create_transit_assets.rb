class CreateTransitAssets < ActiveRecord::Migration[5.2]
  def change
    create_table :transit_assets do |t|
      t.references :transit_assetible, polymorphic: true, index: {name: :transit_assetible_idx}
      t.references :asset, index: true

      t.references  :fta_asset_category, index: true, null: false
      t.references  :fta_class, index: true, null: false
      t.references  :fta_type, polymorphic: true, index: true, null: false
      t.integer     :fta_type_id, null: false
      t.integer     :pcnt_capital_responsibility
      t.string      :contract_num
      t.references  :contract_type
      t.boolean   :has_warranty
      t.date      :warranty_date

      t.timestamps
    end
  end
end
