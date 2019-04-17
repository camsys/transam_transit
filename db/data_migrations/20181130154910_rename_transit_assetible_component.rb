class RenameTransitAssetibleComponent < ActiveRecord::DataMigration
  def up
    TransitAsset.where(transit_assetible_type: 'Component').update_all(transit_assetible_type: 'TransitComponent')
  end
end