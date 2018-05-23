class MoveAssetsToTransitAssets < ActiveRecord::DataMigration
  def up
    puts "#{Asset.count} assets."
    puts "#{Asset.operational.count} operational."
    puts "#{Asset.disposed.count} disposed."
    puts "#{Asset.where('object_key = asset_tag').count} in transfer."

    # Vehicle / Rail Car / Locomotive
    rev_vehicle_cols = RevenueVehicle.new.attributes.keys.reject{|x| ['id', 'object_key'].include? x}
    rev_vehicle_category = FtaAssetCategory.find_by(name: 'Revenue Vehicles')
    Asset.where(asset_type: AssetType.where(class_name: ['Vehicle', 'RailCar', 'Locomotive'])).each do |vehicle|
      x = RevenueVehicle.create!(vehicle.attributes.slice(*rev_vehicle_cols).merge({asset_id: vehicle.id, fta_asset_category_id: rev_vehicle_category.id, fta_asset_class_id: FtaVehicleType.find_by(id: vehicle.fta_vehicle_type_id).fta_asset_class_id}))
    end
    puts "Did not transfer #{(Asset.new.attributes.keys - rev_vehicle_cols).inspect}"

    # SupportVehicle
    service_vehicle_cols = ServiceVehicle.new.attributes.keys.reject{|x| ['id', 'object_key'].include? x}
    equipment_category = FtaAssetCategory.find_by(name: 'Equipment')
    service_vehicle_class = FtaAssetClass.find_by(name: 'Service Vehicles (Non-Revenue)')
    SupportVehicle.all.each do |vehicle|
      ServiceVehicle.create!(vehicle.attributes.slice(*service_vehicle_cols).merge({asset_id: vehicle.id, fta_asset_category_id: equipment_category.id, fta_asset_class_id: service_vehicle_class.id}))
    end
    puts "Did not transfer #{(Asset.new.attributes.keys - service_vehicle_cols).inspect}"

    # Transit/Support Facility
    facility_cols = Facility.new.attributes.keys.reject{|x| ['id', 'object_key'].include? x}
    facility_category = FtaAssetCategory.find_by(name: 'Facilities')
    Asset.where(asset_type: AssetType.where(class_name: ['TransitFacility', 'SupportFacility'])).each do |facility|
      Facility.create!(facility.attributes.slice(*facility_cols).merge({asset_id: facility.id, fta_asset_category_id: facility_category.id, fta_asset_class_id: FtaFacilityType.find_by(id: facility.fta_facility_type_id).fta_asset_class_id}))
    end
    puts "Did not transfer #{(Asset.new.attributes.keys - facility_cols).inspect}"

    # Equipment
    cap_equipment_cols = CapitalEquipment.new.attributes.keys.reject{|x| ['id', 'object_key'].include? x}
    equipment_class = FtaAssetClass.find_by(name: 'Capital Equipment')
    Equipment.all.each do |equipment|
      CapitalEquipment.create!(equipment.attributes.slice(*cap_equipment_cols).merge({asset_id: equipment.id, fta_asset_category_id: equipment_category.id, fta_asset_class_id: equipment_class.id}))
    end
    puts "Did not transfer #{(Asset.new.attributes.keys - cap_equipment_cols).inspect}"

  end
end