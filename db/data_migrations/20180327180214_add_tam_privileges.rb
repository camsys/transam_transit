class AddTamPrivileges < ActiveRecord::DataMigration
  def up
    [
        {name: 'tam_manager', role_parent_id: Role.find_by(name:'manager').id, privilege: true, label: 'TAM Manager', show_in_user_mgmt: true},
        {name: 'tam_group_lead', privilege: true, label: 'TAM Group Lead', show_in_user_mgmt: false}
    ].each do |privilege|
      r = Role.find_or_initialize_by(name: privilege[:name])
      r.update!(privilege)
    end
  end

  def down
    Role.where(name: ['tam_manager', 'tam_group_lead']).destroy_all
  end
end