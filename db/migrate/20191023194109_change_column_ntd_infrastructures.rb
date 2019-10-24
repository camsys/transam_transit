class ChangeColumnNtdInfrastructures < ActiveRecord::Migration[5.2]
  def change
    change_column :ntd_infrastructures, :linear_miles, :decimal, precision: 7, scale: 2
    change_column :ntd_infrastructures, :track_miles, :decimal, precision: 7, scale: 2

    add_column :fta_track_types, :sort_order, :integer
    add_column :fta_power_signal_types, :sort_order, :integer
    add_column :fta_guideway_types, :sort_order, :integer
  end
end
