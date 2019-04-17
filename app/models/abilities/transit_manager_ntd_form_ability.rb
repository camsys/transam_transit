module Abilities
  class TransitManagerNtdFormAbility
    include CanCan::Ability

    def initialize(user, organization_ids=[])

      if organization_ids.empty?
        organization_ids = user.organization_ids
      end

      can :manage, NtdForm do |ntd_form|
        organization_ids.include?(ntd_form.organization_id)
      end

      can :manage, NtdReport do |ntd_report|
        organization_ids.include?(ntd_report.ntd_form.organization_id)
      end

    end
  end
end