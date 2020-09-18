module Abilities
  class TransitManagerUserAbility
    include CanCan::Ability

    def initialize(user, organization_ids=[])

      if organization_ids.empty?
        organization_ids = user.organization_ids
      end


      can [:table, :create, :reset_password, :destroy, :update, :authorizations], User do |u|
        (organization_ids.include? u.organization_id and user.id != u.id)
      end

    end
  end
end
