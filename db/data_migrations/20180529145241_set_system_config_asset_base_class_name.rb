class SetSystemConfigAssetBaseClassName < ActiveRecord::DataMigration
  def up
    SystemConfig.instance.update!(asset_base_class_name: 'FtaAssetClass')
  end
end