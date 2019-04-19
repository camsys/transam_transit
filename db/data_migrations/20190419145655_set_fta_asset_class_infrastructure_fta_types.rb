class SetFtaAssetClassInfrastructureFtaTypes < ActiveRecord::DataMigration
  def up

    FtaTrackType.update_all(fta_asset_class_id: FtaAssetClass.find_by(class_name: 'Track').id)
    FtaGuidewayType.update_all(fta_asset_class_id: FtaAssetClass.find_by(class_name: 'Guideway').id)
    FtaPowerSignalType.update_all(fta_asset_class_id: FtaAssetClass.find_by(class_name: 'PowerSignal').id)

  end
end