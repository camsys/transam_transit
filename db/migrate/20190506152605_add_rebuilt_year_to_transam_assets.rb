class AddRebuiltYearToTransamAssets < ActiveRecord::Migration[5.2]
  def change
    add_column :transam_assets, :rebuilt_year, :integer
  end
end
