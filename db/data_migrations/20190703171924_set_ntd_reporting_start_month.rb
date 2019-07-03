class SetNtdReportingStartMonth < ActiveRecord::DataMigration
  def up
    Organization.update_all(ntd_reporting_start_month: 7)
  end
end