module Abilities
  class TransitManagerActivityLogAbility
    include CanCan::Ability

    def initialize(user, organization_ids=[])

      can :read, ActivityLog

    end
  end
end