class AddPolicyReplacementCoreMixins < ActiveRecord::DataMigration
  def up
    SystemConfigExtension.find_or_create_by(class_name: 'TransamAsset', extension_name: 'PolicyAware', active: true)
    SystemConfigExtension.find_or_create_by(class_name: 'TransamAsset', extension_name: 'ReplaceableAsset', active: true)
  end
end