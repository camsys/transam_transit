module Abilities
  class TransitManagerAssetFleetAbility
    include CanCan::Ability

    def initialize(user, organization_ids=[])

      if organization_ids.empty?
        organization_ids = user.organization_ids
      end

      can :manage, AssetFleet do |fleet|
        organization_ids.include?(fleet.organization_id)
      end

    end
  end
end