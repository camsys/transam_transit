class AddTransitSystemConfigExtensions < ActiveRecord::DataMigration
  def up
    system_config_extensions = [
        {class_name: 'TransitAsset', extension_name: 'TransamKeywordSearchable', active: true}
    ]

    system_config_extensions.each do |extension|
      SystemConfigExtension.create!(extension)
    end
  end
end