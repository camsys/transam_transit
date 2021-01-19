class CreateFtaTypeAssetSubtypeMap < ActiveRecord::Migration[5.2]
  def change
    create_table :fta_type_asset_subtype_mappings do |t|
      t.references :fta_type, polymorphic: true, index: {name: :fta_type_asset_subtype_mappings_idx}, null: false
      t.references :asset_subtype, index: true, null: false
    end
  end
end
