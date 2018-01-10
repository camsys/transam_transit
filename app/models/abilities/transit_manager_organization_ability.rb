module Abilities
  class TransitManagerOrganizationAbility
    include CanCan::Ability

    def initialize(user, organization_ids=[])

      if organization_ids.empty?
        organization_ids = user.organization_ids
      end


      # can update organization records if they are in their list
      can :update, Organization do |org|
        organization_ids.include?(org.id)
      end

    end
  end
end