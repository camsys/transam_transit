# frozen_string_literal: true

class NullTransitAssetAssetId < ActiveRecord::DataMigration
  def up
    TransitAsset.where.not(asset_id: nil).update_all(asset_id: nil)
  end
end