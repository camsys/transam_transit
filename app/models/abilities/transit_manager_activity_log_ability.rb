module Abilities
  class TransitManagerActivityLogAbility
    include CanCan::Ability

    def initialize(user)

      can :read, ActivityLog

    end
  end
end