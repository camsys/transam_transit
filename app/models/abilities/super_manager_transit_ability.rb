module Abilities
  class SuperManagerTransitAbility
    include CanCan::Ability

    def initialize(user)
      self.merge Abilities::Manager.new(user)
      self.merge Abilities::AssetManager.new(user)
    end
  end
end