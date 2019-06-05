class CleanoutUnusedFtaModeTos < ActiveRecord::DataMigration
  def up
    # Revenue Vehicle can have primary mode, primary TOS, secondary mode, secondary TOS
    # Service Vehicle can have primary mode, secondary modeS
    # facility can have primary mode, secondary modeS


    RevenueVehicle.all.select{|x| x.assets_fta_mode_types.is_primary.count > 1}.each do |vehicle|
      vehicle.assets_fta_mode_types.is_primary.where.not(id: vehicle.assets_fta_mode_types.is_primary.first.id).delete_all
    end
    RevenueVehicle.all.select{|x| x.assets_fta_service_types.is_primary.count > 1}.each do |vehicle|
      vehicle.assets_fta_service_types.is_primary.where.not(id: vehicle.assets_fta_service_types.is_primary.first.id).delete_all
    end
    RevenueVehicle.all.select{|x| x.assets_fta_mode_types.is_not_primary.count > 1}.each do |vehicle|
      vehicle.assets_fta_mode_types.is_not_primary.where.not(id: vehicle.assets_fta_mode_types.is_not_primary.first.id).delete_all
    end
    RevenueVehicle.all.select{|x| x.assets_fta_service_types.is_not_primary.count > 1}.each do |vehicle|
      vehicle.assets_fta_service_types.is_not_primary.where.not(id: vehicle.assets_fta_service_types.is_not_primary.first.id).delete_all
    end

    ServiceVehicle.where(servicible_vehicle_type: nil).select{|x| x.assets_fta_mode_types.is_primary.count > 1}.each do |vehicle|
      vehicle.assets_fta_mode_types.is_primary.where.not(id: vehicle.assets_fta_mode_types.is_primary.first.id).delete_all
    end
    AssetsFtaServiceType.where(transam_asset_type: 'ServiceVehicle').delete_all

    Facility.all.select{|x| x.assets_fta_mode_types.is_primary.count > 1}.each do |facility|
      facility.assets_fta_mode_types.is_primary.where.not(id: facility.assets_fta_mode_types.is_primary.first.id).delete_all
    end
    AssetsFtaServiceType.where(transam_asset_type: 'Facility').delete_all


  end
end