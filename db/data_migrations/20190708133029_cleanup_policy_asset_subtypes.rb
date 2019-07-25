class CleanupPolicyAssetSubtypes < ActiveRecord::DataMigration
  def up
    # Revenue Vehicles
    # Asset Type To FTA Asset Class
    # Revenue Vehicles map to Buses
    # Rail Cars map to Rail Cars
    # Locomotives map to Locomotives
    #                 Create Other

    # Facilities
    # Support Facilities to Administration
    # Transit Facilities to Maintenance, Passenger, Parking

    #Equipment
    # all equipment types to Capital Equipment
    # support vehicle to ServiceVehicle

    # Revenue Vehicles


    # Organization.all.each do |org|
    #
    #   # data check of assets
    #   # revenue vehicles
    #   TransitAsset.where(organization: org, asset_subtype: AssetSubtype.where(asset_type: AssetType.find_by(class_name: 'Vehicle'))).where.not(transit_assets: {fta_asset_class_id: FtaAssetClass.where(name: ['Buses (Rubber Tire Vehicles)', 'Other Passenger Vehicles']).pluck(:id)})
    #   TransitAsset.where(organization: org, asset_subtype: AssetSubtype.where(asset_type: AssetType.find_by(class_name: ['RailCar', 'Locomotive']))).where.not(transit_assets: {fta_asset_class_id: FtaAssetClass.find_by(name: 'Rail Cars').id})
    #
    #   # facilities
    #   TransitAsset.where(organization: org, asset_subtype: AssetSubtype.where(asset_type: AssetType.find_by(class_name: 'SupportFacility'))).where.not(transit_assets: {fta_asset_class_id: FtaAssetClass.where(name: ['Administration']).pluck(:id)})
    #   TransitAsset.where(organization: org, asset_subtype: AssetSubtype.where(asset_type: AssetType.find_by(class_name: 'TransitFacility'))).where.not(transit_assets: {fta_asset_class_id: FtaAssetClass.where(name: ['Maintenance', 'Passenger', 'Parking']).pluck(:id)})
    #
    #   # equipment
    #   TransitAsset.where(organization: org, asset_subtype: AssetSubtype.where(asset_type: AssetType.find_by(class_name: 'Equipment'))).where.not(transit_assets: {fta_asset_class_id: FtaAssetClass.where(name: ['Capital Equipment']).pluck(:id)})
    #
    #   # service vehicles
    #   TransitAsset.where(organization: org, asset_subtype: AssetSubtype.where(asset_type: AssetType.find_by(class_name: 'SupportVehicle'))).where.not(transit_assets: {fta_asset_class_id: FtaAssetClass.where(name: ['Service Vehicles (Non-Revenue)']).pluck(:id)})
    #
    #
    #
    #   # data check of policies
    #
    #   # revenue vehicles
    #   PolicyAssetTypeRule.where(policy: Policy.find_by(organization_id: org.id), asset_type: AssetType.where(class_name: ['RailCar', 'Locomotive'])).distinct.pluck(:service_life_calculatition_type_id, :replacement_cost_calculation_type_id, :annual_inflation_rate, :pcnt_residual_value).count > 1
    #
    #   # equipment
    #   PolicyAssetTypeRule.where(policy: Policy.find_by(organization_id: org.id), asset_type: AssetType.where(class_name: 'Equipment')).distinct.pluck(:service_life_calculatition_type_id, :replacement_cost_calculation_type_id, :annual_inflation_rate, :pcnt_residual_value).count > 1
    #
    #
    #   # updates
    #
    #   # revenue vehicles
    #
    #   AssetSubtype.where(asset_type: AssetType.where(class_name: 'Locomotive')).update_all(asset_type_id: AssetType.find_by(class_name: 'RailCar').id)
    #   AssetType.create(name: 'Other Passenger Vehicles')
    #
    #   # facilities
    #   AssetSubtype.create
  end
end