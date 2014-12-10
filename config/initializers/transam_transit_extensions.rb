# Technique caged from http://stackoverflow.com/questions/4460800/how-to-monkey-patch-code-that-gets-auto-loaded-in-rails
Rails.configuration.to_prepare do
  Asset.class_eval do
    include TransamTransitAsset
  end
  PolicyItem.class_eval do
    include TransamTransit::TransamTransitPolicyItem
  end
end