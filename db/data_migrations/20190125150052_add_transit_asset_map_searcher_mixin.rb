class AddTransitAssetMapSearcherMixin < ActiveRecord::DataMigration
  def up
    SystemConfigExtension.create!({class_name: 'AssetMapSearcher', extension_name: 'TransitAssetMapSearchable', active: true})
  end

  def down
    SystemConfigExtension.find_by({class_name: 'AssetMapSearcher', extension_name: 'TransitAssetMapSearchable', active: true}).destroy
  end
end