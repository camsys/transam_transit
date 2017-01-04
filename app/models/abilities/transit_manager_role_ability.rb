module Abilities
  class TransitManagerRoleAbility
    include CanCan::Ability

    def initialize(user)

      can :assign, Role do |r|
        ['guest', 'user', 'transit_manager', 'technical_contact', 'director_transit_operations', 'ntd_contact'].include? r.name
      end

    end
  end
end