class CleanupAdminFtaFacilityType < ActiveRecord::DataMigration
  def up
    FtaFacilityType.find_by(name: 'Administrative Office/Sales Office').update!(name: 'Administrative Office / Sales Office')
  end
end