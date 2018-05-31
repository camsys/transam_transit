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
      fta_vehicle_type = FtaVehicleType.find_by(id: vehicle.fta_vehicle_type_id)
      x = RevenueVehicle.create!(vehicle.attributes.slice(*rev_vehicle_cols).merge({asset_id: vehicle.id, fta_asset_category_id: rev_vehicle_category.id, fta_asset_class_id: fta_vehicle_type.fta_asset_class_id, fta_type: fta_vehicle_type}))
    end
    puts "Did not transfer #{(Asset.new.attributes.keys - rev_vehicle_cols).inspect}"

    # SupportVehicle
    service_vehicle_cols = ServiceVehicle.new.attributes.keys.reject{|x| ['id', 'object_key'].include? x}
    equipment_category = FtaAssetCategory.find_by(name: 'Equipment')
    service_vehicle_class = FtaAssetClass.find_by(name: 'Service Vehicles (Non-Revenue)')
    SupportVehicle.all.each do |vehicle|
      ServiceVehicle.create!(vehicle.attributes.slice(*service_vehicle_cols).merge({asset_id: vehicle.id, fta_asset_category_id: equipment_category.id, fta_asset_class_id: service_vehicle_class.id, fta_type: vehicle.fta_support_vehicle_type}))
    end
    puts "Did not transfer #{(Asset.new.attributes.keys - service_vehicle_cols).inspect}"

    # Transit/Support Facility
    facility_cols = Facility.new.attributes.keys.reject{|x| ['id', 'object_key'].include? x}
    facility_category = FtaAssetCategory.find_by(name: 'Facilities')
    Asset.where(asset_type: AssetType.where(class_name: ['TransitFacility', 'SupportFacility'])).each do |facility|
      fta_facility_type = FtaFacilityType.find_by(id: facility.fta_facility_type_id)
      Facility.create!(facility.attributes.slice(*facility_cols).merge({asset_id: facility.id, fta_asset_category_id: facility_category.id, fta_asset_class_id: fta_facility_type.fta_asset_class_id, fta_type: fta_facility_type}))
    end
    puts "Did not transfer #{(Asset.new.attributes.keys - facility_cols).inspect}"

    # Equipment
    cap_equipment_cols = CapitalEquipment.new.attributes.keys.reject{|x| ['id', 'object_key'].include? x}
    equipment_class = FtaAssetClass.find_by(name: 'Capital Equipment')
    Equipment.all.each do |equipment|
      CapitalEquipment.create!(equipment.attributes.slice(*cap_equipment_cols).merge({asset_id: equipment.id, fta_asset_category_id: equipment_category.id, fta_asset_class_id: equipment_class.id, fta_type: FtaEquipmentType.first})) # temporarily set to first equipment type
    end
    # puts "Did not transfer #{(Asset.new.attributes.keys - cap_equipment_cols).inspect}"

    # move asset groups
    AssetGroupsAsset.all.each do |a|
      a.update_columns(transam_asset_id: TransitAsset.find_by(asset_id: a.asset_id).transam_asset.id)
    end

    # move asset events
    AssetEvent.all.each do |a|
      a.update_columns(transam_asset_id: TransitAsset.find_by(asset_id: a.asset_id).transam_asset.id)
    end

    # move other generic associations like comments/docs/photos
    Comment.where(commentable_type: 'Asset').each do |thing|
      new_thing = thing.dup
      new_thing.commentable = TransitAsset.find_by(asset: thing.commentable).transam_asset
      new_thing.object_key = nil
      new_thing.save!
    end
    Image.where(imagable_type: 'Asset').each do |thing|
      new_thing = thing.dup
      new_thing.imagable = TransitAsset.find_by(asset: thing.imagable).transam_asset
      new_thing.object_key = nil
      new_thing.save!
    end
    Document.where(documentable_type: 'Asset').each do |thing|
      new_thing = thing.dup
      new_thing.documentable = TransitAsset.find_by(asset: thing.documentable).transam_asset
      new_thing.object_key = nil
      new_thing.save!
    end
    Task.where(taskable_type: 'Asset').each do |thing|
      new_thing = thing.dup
      new_thing.taskable = TransitAsset.find_by(asset: thing.taskable).transam_asset
      new_thing.object_key = nil
      new_thing.save!
    end

    AssetsDistrict.all.each do |a|
      a.update_columns(transam_asset_id: TransitAsset.find_by(asset_id: a.asset_id).transam_asset.id)
    end

  end
end