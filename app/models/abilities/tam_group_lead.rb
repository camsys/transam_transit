module Abilities
  class TamGroupLead
    include CanCan::Ability

    def initialize(user, organization_ids=[])
      if organization_ids.empty?
        organization_ids = user.organization_ids
      end

      # group leads can manage the groups they have been given access to
      can :manage, TamGroup do |g|
        g.leader == user
      end

    end
  end
end