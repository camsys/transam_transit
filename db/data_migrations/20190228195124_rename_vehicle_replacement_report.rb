class RenameVehicleReplacementReport < ActiveRecord::DataMigration
  def up
    
    report = Report.find_by(class_name: "VehicleReplacementReport")
    if report
      report.name = "Revenue Vehicle Replacement Report"
      report.save
    end

  end
end