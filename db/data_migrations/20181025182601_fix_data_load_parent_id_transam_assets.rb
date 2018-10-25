class FixDataLoadParentIdTransamAssets < ActiveRecord::DataMigration
  def up
    TransitAsset.where.not(transam_assets: {parent_id: nil}, transit_assets: {asset_id: nil}).each do |transit_asset|

      if transit_asset.parent_id == transit_asset.asset.parent_id
        transit_asset.parent_id = TransitAsset.find_by(asset_id: transit_asset.asset.parent_id).transam_asset.id
        transit_asset.save(validate: false)
      end
    end
  end
end