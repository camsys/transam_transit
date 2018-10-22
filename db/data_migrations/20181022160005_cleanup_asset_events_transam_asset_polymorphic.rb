class CleanupAssetEventsTransamAssetPolymorphic < ActiveRecord::DataMigration
  def up
    AssetEvent.all.each do |asset_event|
      typed_event = AssetEvent.as_typed_event(asset_event)

      # database updated so that transam asset is polymorphic as well as base asset event but each class of asset event also defines a
      # belongs_to :transam_asset, class_name: 'XXX'
      # if it is known it is associated with a typed class of TransamAsset further up the ERD
      # therefore we can use this info to update the database
      if typed_event.transam_asset.nil?
        typed_event.update_columns(transam_asset_type: 'TransamAsset')
      else
        typed_event.update_columns(transam_asset_type: typed_event.transam_asset.class.to_s)
      end
    end
  end
end