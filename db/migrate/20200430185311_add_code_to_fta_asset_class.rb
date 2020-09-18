class AddCodeToFtaAssetClass < ActiveRecord::Migration[5.2]
  def change
    add_column :fta_asset_classes, :code, :string, null: false 
  end
end
