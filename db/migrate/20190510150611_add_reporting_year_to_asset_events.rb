class AddReportingYearToAssetEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :asset_events, :reporting_year, :integer
    add_column :asset_events, :ntd_report_mileage, :integer
  end
end
