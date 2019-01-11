class AddRolesOrgTypes < ActiveRecord::DataMigration
  def up
    OrganizationType.find_by(class_name: 'Grantor').update!(roles: 'guest,manager')
    OrganizationType.find_by(class_name: 'TransitOperator').update!(roles: 'guest,user,transit_manager')
    OrganizationType.find_by(class_name: 'PlanningPartner').update!(roles: 'guest')
  end
end