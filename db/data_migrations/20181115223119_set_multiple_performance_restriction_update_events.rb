class SetMultiplePerformanceRestrictionUpdateEvents < ActiveRecord::DataMigration
  def up
    PerformanceRestrictionUpdateEvent.all.each{|x| x.update_columns(num_infrastructure: x.tracks.count)}
  end
end