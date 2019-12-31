class RemoveTrackGradientPcntTrackGradientDegreeFromQueryTool < ActiveRecord::DataMigration
  def up
    QueryField.where(name: ['track_gradient_pcnt', 'track_gradient_degree']).destroy_all
  end
end