class AddTransitEngineNameSystemConfigExtensions < ActiveRecord::DataMigration
  def up
    system_config_extensions = [
        {class_name: 'TransamAsset', extension_name: 'PolicyAware', active: true},
        {class_name: 'TransamAsset', extension_name: 'ReplaceableAsset', active: true}
    ]
    if SystemConfig.transam_module_loaded? :spatial
      system_config_extensions += [
          {class_name: 'Facility', extension_name: 'TransamAddressLocatable', active: true},
          {class_name: 'ServiceVehicle', extension_name: 'TransamParentLocatable', active: true},
          {class_name: 'CapitalEquipment', extension_name: 'TransamParentLocatable', active: true},
          {class_name: 'Infrastructure', extension_name: 'TransamCoordinateLocatable', active: true},
          {class_name: 'AssetMapSearcher', extension_name: 'TransitAssetMapSearchable', active: true}
      ]
    end

    system_config_extensions.each do |config|
      SystemConfigExtension.find_by(config).update!(engine_name: 'transit')
    end
  end
end