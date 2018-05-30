class AddNotesAssetFleets < ActiveRecord::Migration
  def change
    add_column :asset_fleets, :notes, :text, after: :ntd_id
  end
end
