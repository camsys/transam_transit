class UpdateNtdSeedDataPt3 < ActiveRecord::DataMigration
  def up
    FtaPowerSignalType.find_by(name: 'Train Control and Signaling')&.update!(name: 'Train Control & Signaling')
  end
end
