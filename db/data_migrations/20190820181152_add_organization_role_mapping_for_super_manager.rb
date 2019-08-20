class AddOrganizationRoleMappingForSuperManager < ActiveRecord::DataMigration
  def up
    Grantor.all.each do |g|
      OrganizationRoleMapping.create!(organization_id: g.id, role_id: Role.find_by(name: :super_manager).id)
    end
  end

  def down
    grantor_ids = Grantor.pluck(:id)
    OrganizationRoleMapping.where(organization_id: grantor_ids, role_id: Role.find_by(name: :super_manager).id).destroy_all
  end
end