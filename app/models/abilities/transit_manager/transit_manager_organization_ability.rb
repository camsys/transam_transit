module Abilities
  class TransitManagerOrganizationAbility
    include CanCan::Ability

    def initialize(user)

      # can update organization records if they are in their list
      can :update, Organization do |org|
        user.organization_ids.include?(org.id)
      end

    end
  end
end