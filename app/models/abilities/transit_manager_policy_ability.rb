module Abilities
  class TransitManagerPolicyAbility
    include CanCan::Ability

    def initialize(user, organization_ids=[])

      if organization_ids.empty?
        organization_ids = user.organization_ids
      end


      #-------------------------------------------------------------------------
      # Policies
      #-------------------------------------------------------------------------
      # create new policies
      can :create, Policy

      # Policies can be updated if they belong to the organization
      can :update, Policy do |p|
        organization_ids.include? p.organization_id
      end

      # Only grantors can create new rules and then only for a top-level policy
      can :create_rules, Policy do |p|
        p.parent.nil? and user.organization.organization_type.class_name == "Grantor"
      end

      # can remove policies if they are not current and are in their organizations list
      can :destroy, Policy do |p|
        p.active == false and organization_ids.include? p.organization_id
      end

    end
  end
end