module Abilities
  class TransitManagerRoleAbility
    include CanCan::Ability

    def initialize(user)

      can :assign, Role do |r|
        r.privilege? || (['guest', 'user', 'transit_manager'].include? r.name)
      end

    end
  end
end