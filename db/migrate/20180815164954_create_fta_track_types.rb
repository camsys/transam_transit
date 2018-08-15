class CreateFtaTrackTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :fta_track_types do |t|
      t.string :name
      t.boolean :active
    end
  end
end
