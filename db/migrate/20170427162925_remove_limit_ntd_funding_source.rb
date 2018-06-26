class RemoveLimitNtdFundingSource < ActiveRecord::Migration[4.2]
  def change
    #change_column :ntd_revenue_vehicle_fleets, :funding_source, :string, :limit => nil
    change_column :ntd_revenue_vehicle_fleets, :manufacture_code, :string, :limit => nil
  end
end
