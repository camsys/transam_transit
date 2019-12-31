class MoveInfrastructuresGradientPcntDegreeDataToGradient < ActiveRecord::DataMigration
  def up
    Infrastructure.where.not(track_gradient_pcnt: nil).or(Infrastructure.where.not(track_gradient_degree: nil)).each do |i|
      if i.track_gradient_unit == 'percent'
        i.update(track_gradient: i.track_gradient_pcnt)
      elsif i.track_gradient_unit == 'degree'
        i.update(track_gradient: i.track_gradient_degree)
      end
    end
  end
end