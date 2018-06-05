class AddDefaultUsefulLifeBenchmarksFtaTypes < ActiveRecord::Migration[4.2]
  def change
    add_column(:fta_vehicle_types, :default_useful_life_benchmark, :integer, {:after=>:description})
    add_column(:fta_vehicle_types, :useful_life_benchmark_unit, :string, {:after=>:default_useful_life_benchmark})
    add_column(:fta_support_vehicle_types, :default_useful_life_benchmark, :integer, {:after=>:description})
    add_column(:fta_support_vehicle_types, :useful_life_benchmark_unit, :string, {:after=>:default_useful_life_benchmark})
  end
end
