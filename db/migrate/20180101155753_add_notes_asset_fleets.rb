class AddNotesAssetFleets < ActiveRecord::Migration[4.2]
  def change
    add_column :asset_fleets, :notes, :text, after: :ntd_id
  end
end
