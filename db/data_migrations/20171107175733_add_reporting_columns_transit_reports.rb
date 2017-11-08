class AddReportingColumnsTransitReports < ActiveRecord::DataMigration
  def up
    Report.find_by(name: 'Vehicle Replacement Report').update!(printable: true, exportable: true) if Report.find_by(name: 'Vehicle Replacement Report')
    Report.find_by(name: 'State of Good Repair Report').update!(printable: true, exportable: true) if Report.find_by(name: 'State of Good Repair Report')
    Report.find_by(name: 'Disposition Report').update!(printable: true, exportable: true) if Report.find_by(name: 'Disposition Report')
  end
end