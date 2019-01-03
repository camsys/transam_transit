class FixesMoveAssetsTransamAssets < ActiveRecord::DataMigration
  def up
    # fix bad mapping of old Asset to TransamAsset of fta_type for Maintenance Equipment
    TransitAsset.where(asset: Asset.where(asset_subtype: AssetSubtype.where(asset_type: AssetType.find_by(name: 'Maintenance Equipment')).where.not(name: 'Fare Collection Systems'))).update_all(fta_type_type: 'FtaEquipmentType', fta_type_id: FtaEquipmentType.find_by(name: 'Maintenance Equipment').id)

    # fix bad mapping of old Asset to TransamAsset of fta_type for Communications Equipment
    TransitAsset.where(asset: Asset.where(asset_subtype: AssetSubtype.where(asset_type: AssetType.find_by(name: 'Communications Equipment')).where.not(name: 'Surveillance & Security'))).update_all(fta_type_type: 'FtaEquipmentType', fta_type_id: FtaEquipmentType.find_by(name: 'Communications Equipment').id)

  end
end