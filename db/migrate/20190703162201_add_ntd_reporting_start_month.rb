class AddNtdReportingStartMonth < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :ntd_reporting_start_month, :integer
  end
end
