class AddUploadIdToAssetEvents < ActiveRecord::Migration
  def up
  	add_column    :asset_events, :upload_id, :integer, :after => :asset_event_type_id
  end
  def down
  	remove_column :asset_events, :upload_id
  end
end
