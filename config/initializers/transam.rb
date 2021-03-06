# Technique caged from http://stackoverflow.com/questions/4460800/how-to-monkey-patch-code-that-gets-auto-loaded-in-rails
Rails.configuration.to_prepare do
  PolicyAssetSubtypeRule.class_eval do
    include TransamTransitPolicyAssetSubtypeRule
  end
  AssetSubtype.class_eval do
    include HasManyFtaTypes
  end
end

Rails.application.config.rails_admin_transit_lookup_tables = ['ComponentType', 'ComponentSubtype', 'FacilityCapacityType', 'FacilityFeature', 'FtaAssetCategory', 'FtaAssetClass', 'FtaEquipmentType', 'FtaFacilityType', 'FtaGuidewayType', 'FtaPowerSignalType', 'FtaSupportVehicleType', 'FtaTrackType', 'FtaVehicleType', 'GoverningBodyType','LeedCertificationType', 'InfrastructureDivision', 'InfrastructureSubdivision', 'InfrastructureTrack', 'FtaAgencyType', 'VehicleRebuildType']
Rails.application.config.rails_admin_transit_models = ['TamPolicy']


# temporarily set a config on which assets to audit
begin
  Rails.application.config.asset_auditor_config = {class_name: 'TransitAsset', query: {fta_asset_category: FtaAssetCategory.where.not(name: 'Infrastructure').ids}}
rescue
  puts "skipped loading Rails.application.config that depends on DB"
end

