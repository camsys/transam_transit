class FixDataLoadLocationIdTransamAssets < ActiveRecord::DataMigration
  def up
    TransitAsset.where.not(transam_assets: {location_id: nil}, transit_assets: {asset_id: nil}).each do |transit_asset|

      if transit_asset.location_id == transit_asset.asset.location_id
        transit_asset.location_id = TransitAsset.find_by(asset_id: transit_asset.asset.location_id).transam_asset.id
        transit_asset.save(validate: false)
      end
    end
  end
end