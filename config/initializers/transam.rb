# Technique caged from http://stackoverflow.com/questions/4460800/how-to-monkey-patch-code-that-gets-auto-loaded-in-rails
Rails.configuration.to_prepare do
  PolicyAssetSubtypeRule.class_eval do
    include TransamTransitPolicyAssetSubtypeRule
  end
end

Rails.application.config.rails_admin_transit_lookup_tables = ['FacilityCapacityType', 'FacilityFeature', 'GoverningBodyType','LeedCertificationType', 'InfrastructureDivision', 'InfrastructureSubdivision', 'InfrastructureTrack']
Rails.application.config.rails_admin_transit_models = ['District', 'TamPolicy']
