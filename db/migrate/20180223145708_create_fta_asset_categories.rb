class CreateFtaAssetCategories < ActiveRecord::Migration[4.2]
  def change
    create_table :fta_asset_categories do |t|
      t.string :name
      t.boolean :active
    end

    create_table :tam_groups_fta_asset_categories, id: false do |t|
      t.belongs_to :tam_group
      t.belongs_to :fta_asset_category
    end

    add_column :tam_performance_metrics, :fta_asset_category_id, :integer, after: :tam_group_id
  end
end
