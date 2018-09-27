class CreateDisplayIconNameFtaAssetCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :fta_asset_categories, :display_icon_name, :string, after: :name
  end
end
