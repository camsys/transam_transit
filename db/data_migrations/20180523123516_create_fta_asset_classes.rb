class CreateFtaAssetClasses < ActiveRecord::DataMigration
  def up
    fta_asset_classes = [
        {fta_category: 'Revenue Vehicles', name: 'Buses (Rubber Tire Vehicles)', class_name: 'RevenueVehicle', active: true},
        {fta_category: 'Revenue Vehicles', name: 'Rail Cars', class_name: 'RevenueVehicle', active: true},
        {fta_category: 'Revenue Vehicles', name: 'Ferries', class_name: 'RevenueVehicle', active: true},
        {fta_category: 'Revenue Vehicles', name: 'Other Passenger Vehicles', class_name: 'RevenueVehicle', active: true},
        {fta_category: 'Equipment', name: 'Service Vehicles (Non-Revenue)', class_name: 'ServiceVehicle', active: true},
        {fta_category: 'Equipment', name: 'Capital Equipment', class_name: 'CapitalEquipment', active: true},
        {fta_category: 'Facilities', name: 'Administration', class_name: 'Facility', active: true},
        {fta_category: 'Facilities', name: 'Maintenance', class_name: 'Facility', active: true},
        {fta_category: 'Facilities', name: 'Passenger', class_name: 'Facility', active: true},
        {fta_category: 'Facilities', name: 'Parking', class_name: 'Facility', active: true},
        {fta_category: 'Infrastructure', name: 'Guideway', class_name: 'Guideway', active: true},
        {fta_category: 'Infrastructure', name: 'Power & Signal', class_name: 'PowerSignal', active: true},
        {fta_category: 'Infrastructure', name: 'Track', class_name: 'Track', active: true}

    ]

    fta_asset_classes.each do |klass|
      f = FtaAssetClass.new(klass.except(:fta_category))
      f.fta_asset_category = FtaAssetCategory.find_by(name: klass[:fta_category])
      f.save!
    end

  end
end