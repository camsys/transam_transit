class CreateAssetTypeInfoLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :asset_type_info_logs do |t|
      t.references :transam_asset, polymorphic: true, index: {name: :asset_type_info_log_idx}, null: false
      t.references :fta_asset_class, index: true
      t.references :fta_type, polymorphic: true, index: true
      t.references :asset_subtype, index: true
      t.references :created_by, index: true, null: false

      t.timestamps
    end
  end
end
