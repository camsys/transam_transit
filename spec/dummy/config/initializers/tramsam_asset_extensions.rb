# Add asset plugins for this app
Rails.configuration.to_prepare do
  Asset.class_eval do
    # Transit
    include TransamTransitAsset
  end
  Organization.class_eval do
    include TestTransamAccountableOrg
  end
end

### TEMP EXTENSION FOR org association with grants
### currently in accounting -- needs to be fixed
module TestTransamAccountableOrg
  #------------------------------------------------------------------------------
  #
  # Accountable
  #
  # Injects methods and associations for managing depreciable assets into an
  # Organization class
  #
  # Model
  #
  #------------------------------------------------------------------------------
  extend ActiveSupport::Concern

  included do
    has_many :grants
  end
end
