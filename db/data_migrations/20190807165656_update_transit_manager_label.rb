class UpdateTransitManagerLabel < ActiveRecord::DataMigration
  def up
    Role.find_by(name: 'transit_manager').update(label: 'Manager')
  end

  def down
    Role.find_by(name: 'transit_manager').update(label: nil)
  end
end