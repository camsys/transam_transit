class AddDisplayIconNameFtaAssetCategories < ActiveRecord::DataMigration
  def up
    FtaAssetCategory.find_by(name: 'Revenue Vehicles').update!(display_icon_name: 'fa fa-bus')
    FtaAssetCategory.find_by(name: 'Equipment').update!(display_icon_name: 'fa fa-cog')
    FtaAssetCategory.find_by(name: 'Facilities').update!(display_icon_name: 'fa fa-building')
    FtaAssetCategory.find_by(name: 'Infrastructure').update!(display_icon_name: 'fa fa-road')
  end
end