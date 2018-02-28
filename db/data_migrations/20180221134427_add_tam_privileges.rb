class AddTamPrivileges < ActiveRecord::DataMigration
  def up
    [
        {name: 'tam_manager', resource_role: 'manager', privilege: true, label: 'TAM Manager'},
        {name: 'tam_group_lead', resource_role: 'transit_manager', privilege: true, label: 'TAM Group Lead'}
    ].each do |privilege|
      r = Role.new(privilege.except(:resource_role))
      r.resource = Role.find_by(name: privilege[:resource_role])
      r.save!
    end
  end

  def down
    Role.where(name: ['tam_manager', 'tam_group_lead']).destroy_all
  end
end