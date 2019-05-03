class AddFtaClassInfrastructureFtaTypes < ActiveRecord::Migration[5.2]
  def change
    add_reference :fta_track_types, :fta_asset_class, after: :id
    add_reference :fta_guideway_types, :fta_asset_class, after: :id
    add_reference :fta_power_signal_types, :fta_asset_class, after: :id
  end
end
