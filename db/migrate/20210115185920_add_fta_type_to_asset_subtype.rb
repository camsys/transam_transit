class AddFtaTypeToAssetSubtype < ActiveRecord::Migration[5.2]
  def change
    add_reference :asset_subtypes, :fta_type, polymorphic: true, index: true, after: :asset_type_id
  end
end
