class SanitizeSegmentUnitStringsToMile < ActiveRecord::DataMigration
  def up
    Infrastructure.where.not(from_line: nil, segment_unit: 'mile').update_all(segment_unit: 'mile')
  end
end