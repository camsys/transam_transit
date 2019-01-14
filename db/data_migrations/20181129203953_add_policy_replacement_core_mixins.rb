class AddPolicyReplacementCoreMixins < ActiveRecord::DataMigration
  def up
    SystemConfigExtension.create(class_name: 'TransamAsset', extension_name: 'PolicyAware')
    SystemConfigExtension.create(class_name: 'TransamAsset', extension_name: 'ReplaceableAsset')
  end
end