module Abilities
  class TransitManagerAssetAbility
    include CanCan::Ability

    def initialize(user)

      # Only allow users to dispose of assets that are disposable and that they
      # own
      can :dispose, Asset do |a|
        (DispositionUpdateEvent.asset_event_type.try(:active) && a.disposable?(false) && user.organization_ids.include?(a.organization_id))
      end

      # Transit managers can destroy assets
      can :destroy, Asset, :organization_id => user.organization_ids

      # Transit managers can accept newly transferred assets
      can :accept_transfers, Asset

    end
  end
end