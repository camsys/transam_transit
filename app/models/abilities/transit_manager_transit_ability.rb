module Abilities
  class TransitManagerTransitAbility
    include CanCan::Ability

    def initialize(user)

      ['ActivityLog', 'Asset', 'Organization', 'Policy', 'Role', 'User'].each do |c|
        ability = "Abilities::TransitManager#{c}Ability".constantize.new(user)

        self.merge ability if ability.present?
      end

    end
  end
end