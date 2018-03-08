module Abilities
  class TransitManagerTamGroupAbility
    include CanCan::Ability

    def initialize(user, organization_ids=[])

      can :manage, TamGroup do |t|
        organization_ids.include? t.organization_id
      end

    end
  end
end