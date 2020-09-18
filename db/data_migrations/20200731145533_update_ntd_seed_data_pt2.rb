class UpdateNtdSeedDataPt2 < ActiveRecord::DataMigration
  def up
    # Use title case, work around the way titleize handles hypens
    FtaTrackType.all.each do |track_type|
      track_type.update!(name: track_type.name.split('-').map(&:titleize).join('-'))
    end
  end
end
