module Abilities
  class TransitManagerTransitAbility
    include CanCan::Ability

    def initialize(user, organization_ids=[])
      if organization_ids.empty?
        organization_ids = user.organization_ids
      end


      ['ActivityLog', 'Asset', 'NtdForm', 'Organization', 'Policy', 'Role', 'TamGroup', 'User'].each do |c|
        ability = "Abilities::TransitManager#{c}Ability".constantize.new(user, organization_ids)

        self.merge ability if ability.present?
      end

    end
  end
end