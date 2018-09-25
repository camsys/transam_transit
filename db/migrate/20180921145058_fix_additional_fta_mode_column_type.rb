class FixAdditionalFtaModeColumnType < ActiveRecord::Migration[5.2]
  def change
    change_column :ntd_revenue_vehicle_fleets, :additional_fta_mode, :string
  end
end
