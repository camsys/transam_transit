module Abilities
  class TamManagerTransitAbility
    include CanCan::Ability

    def initialize(user, organization_ids=[])
      if organization_ids.empty?
        organization_ids = user.organization_ids
      end


      # tam maangers have access to group management section essentially the whole TAM policy
      can :manage, TamPolicy
      can :manage, TamGroup

    end
  end
end