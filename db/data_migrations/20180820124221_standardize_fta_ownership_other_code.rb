class StandardizeFtaOwnershipOtherCode < ActiveRecord::DataMigration
  def up
    FtaOwnershipType.find_by(name: 'Other').update!(code: 'OTHR')
  end
end