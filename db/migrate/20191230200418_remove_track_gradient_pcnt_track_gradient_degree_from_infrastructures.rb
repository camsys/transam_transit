class RemoveTrackGradientPcntTrackGradientDegreeFromInfrastructures < ActiveRecord::Migration[5.2]
  def change
    remove_columns :infrastructures, :track_gradient_pcnt, :track_gradient_degree
  end
end
