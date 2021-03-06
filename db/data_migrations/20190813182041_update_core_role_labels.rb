class UpdateCoreRoleLabels < ActiveRecord::DataMigration
  def up
    Role.where(name: [:user, :manager]).update_all(label: 'Staff')
    Role.find_or_initialize_by(name: :super_manager).update(label: 'Manager', privilege: false, role_parent_id: nil)
  end

  def down
    Role.find_by(name: :super_manager).update(label: nil, privilege: true)
    Role.where(name: [:user, :manager]).update_all(label: nil)
  end
end