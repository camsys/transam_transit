class MakeConditionAndAgeReportsExportable < ActiveRecord::DataMigration
  def up
    ["AssetConditionReport","AssetAgeReport"].each do |name|
      report = Report.find_by(class_name: name)
      if report
        report.exportable = true 
        report.printable = true
        report.save
      end
    end
  end
end