module Abilities
  class TransitManagerAssetAbility
    include CanCan::Ability

    def initialize(user, organization_ids=[])

      if organization_ids.empty?
        organization_ids = user.organization_ids
      end

      # Only allow users to dispose of assets that are disposable and that they
      # own
      can :dispose, Asset do |a|
        (DispositionUpdateEvent.asset_event_type.try(:active) && a.disposable?(false) && organization_ids.include?(a.organization_id))
      end

      # Transit managers can destroy assets
      can :destroy, Asset, :organization_id => organization_ids

      # Transit managers can accept newly transferred assets
      can :accept_transfers, Asset

      # Only allow users to dispose of assets that are disposable and that they
      # own
      can :dispose, TransamAssetRecord do |a|
        (DispositionUpdateEvent.asset_event_type.try(:active) && a.disposable?(false) && organization_ids.include?(a.organization_id))
      end

      # Transit managers can destroy assets
      can :destroy, TransamAssetRecord, :organization_id => organization_ids

      # Transit managers can accept newly transferred assets
      can :accept_transfers, TransamAssetRecord

    end
  end
end