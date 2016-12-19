module Abilities
  class TransitManagerUserAbility
    include CanCan::Ability

    def initialize(user)

      can [:create, :reset_password, :destroy, :update, :authorizations], User do |u|
        (user.organization_ids.include? u.organization_id and user.id != u.id)
      end

    end
  end
end