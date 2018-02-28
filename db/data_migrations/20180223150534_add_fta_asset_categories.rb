class AddFtaAssetCategories < ActiveRecord::DataMigration
  def up
    [
        {name: 'Revenue Vehicles', active: true},
        {name: 'Equipment', active: true},
        {name: 'Facilities', active: true},
        {name: 'Infrastructure', active: true}
    ].each do |category|
      FtaAssetCategory.create!(category)
    end
  end

  def down
    FtaAssetCategory.destroy_all
  end
end