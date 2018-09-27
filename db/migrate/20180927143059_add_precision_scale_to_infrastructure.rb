class AddPrecisionScaleToInfrastructure < ActiveRecord::Migration[5.2]
  def change
    change_table :infrastructures do |t|
      t.change :from_segment, :decimal, precision: 7, scale: 2
      t.change :to_segment, :decimal, precision: 7, scale: 2
      t.change :relative_location, :decimal, precision: 10, scale: 5
      t.change :gauge, :decimal, precision: 10, scale: 5
      t.change :track_gradient_pcnt, :decimal, precision: 10, scale: 5
      t.change :track_gradient_degree, :decimal, precision: 10, scale: 5
      t.change :track_gradient, :decimal, precision: 10, scale: 5
      t.change :horizontal_alignment, :decimal, precision: 10, scale: 5
      t.change :vertical_alignment, :decimal, precision: 10, scale: 5
      t.change :length, :decimal, precision: 10, scale: 5
      t.change :height, :decimal, precision: 10, scale: 5
      t.change :width, :decimal, precision: 10, scale: 5
      t.change :crosslevel, :decimal, precision: 10, scale: 5
      t.change :warp_parameter, :decimal, precision: 10, scale: 5
      t.change :track_curvature, :decimal, precision: 10, scale: 5
      t.change :track_curvature_degree, :decimal, precision: 10, scale: 5
      t.change :cant, :decimal, precision: 10, scale: 5
      t.change :cant_gradient, :decimal, precision: 10, scale: 5
      t.change :max_permissible_speed, :decimal, precision: 10, scale: 5
    end
  end
end
