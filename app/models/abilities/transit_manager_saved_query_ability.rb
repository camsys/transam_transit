module Abilities
  class TransitManagerSavedQueryAbility
    include CanCan::Ability

    def initialize(user, organization_ids=[])
      # own org's manager can edit and share a saved query
      can :manage, SavedQuery do |query|
        user.organization_id == query.created_by_user.try(:organization_id)
      end
    end
  end
end