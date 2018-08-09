class CreateFtaAssetClasses < ActiveRecord::DataMigration
  def up
    fta_asset_classes = [
        {fta_category: 'Revenue Vehicles', name: 'Buses (Rubber Tire Vehicles)', class_name: 'RevenueVehicle', display_icon_name: 'fa fa-bus', active: true},
        {fta_category: 'Revenue Vehicles', name: 'Rail Cars', class_name: 'RevenueVehicle', display_icon_name: 'fa fa-subway', active: true},
        {fta_category: 'Revenue Vehicles', name: 'Ferries', class_name: 'RevenueVehicle', display_icon_name: 'fa fa-ship', active: true},
        {fta_category: 'Revenue Vehicles', name: 'Other Passenger Vehicles', class_name: 'RevenueVehicle', display_icon_name: 'fa fa-train', active: true},
        {fta_category: 'Equipment', name: 'Service Vehicles (Non-Revenue)', class_name: 'ServiceVehicle', display_icon_name: 'fa fa-car', active: true},
        {fta_category: 'Equipment', name: 'Capital Equipment', class_name: 'CapitalEquipment', display_icon_name: 'fa fa-map-signs', active: true},
        {fta_category: 'Facilities', name: 'Administration', class_name: 'RevenueVehicle', display_icon_name: 'fa fa-university', active: true},
        {fta_category: 'Facilities', name: 'Maintenance', class_name: 'RevenueVehicle', display_icon_name: 'fa fa-wrench', active: true},
        {fta_category: 'Facilities', name: 'Passenger', class_name: 'RevenueVehicle', display_icon_name: 'fa fa-user', active: true},
        {fta_category: 'Facilities', name: 'Parking', class_name: 'RevenueVehicle', display_icon_name: 'fa fa-road', active: true},
        {fta_category: 'Infrastructure', name: 'Guideway', class_name: 'Guideway', display_icon_name: 'fa fa-map', active: true},
        {fta_category: 'Infrastructure', name: 'Power & Signal', class_name: 'PowerSignal', display_icon_name: 'fa fa-plug', active: true},
        {fta_category: 'Infrastructure', name: 'Track', class_name: 'Track', display_icon_name: 'fa fa-train', active: true}
    ]

    fta_asset_classes.each do |klass|
      f = FtaAssetClass.new(klass.except(:fta_category))
      f.fta_asset_category = FtaAssetCategory.find_by(name: klass[:fta_category])
      f.save!
    end

  end
end