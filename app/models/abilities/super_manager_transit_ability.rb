module Abilities
  class SuperManagerTransitAbility
    include CanCan::Ability

    def initialize(user)
      self.merge(Abilities::Manager).new(user)
    end
  end
end