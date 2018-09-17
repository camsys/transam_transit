class AddFtaAssetCategories < ActiveRecord::DataMigration
  def up
    [
        {name: 'Revenue Vehicles', display_icon_name: 'fa fa-bus', active: true},
        {name: 'Equipment', display_icon_name: 'fa fa-cog', active: true},
        {name: 'Facilities', display_icon_name: 'fa fa-building', active: true},
        {name: 'Infrastructure', display_icon_name: 'fa fa-bolt', active: true}
    ].each do |category|
      FtaAssetCategory.create!(category)
    end
  end

  def down
    FtaAssetCategory.destroy_all
  end
end