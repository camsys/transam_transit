class RemoveUnusedReports < ActiveRecord::DataMigration
  def up
    #Delete these reports from the DB
    report = Report.find_by(name: "Useful Life Consumed Report")
    if report
      report.delete
    end

    report = Report.find_by(name: "Asset Subtype Report")
    if report
      report.delete
    end

  end
end