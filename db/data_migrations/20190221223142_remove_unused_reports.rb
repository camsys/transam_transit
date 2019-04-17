class RemoveUnusedReports < ActiveRecord::DataMigration
  def up
    #Delete these reports from the DB
    report = Report.find_by(class_name: "ServiceLifeConsumedReport")
    if report
      report.active = false
      report.save
    end

    report = Report.find_by(class_name: "AssetSubtypeReport")
    if report
      report.active = false
      report.save
    end

  end
end