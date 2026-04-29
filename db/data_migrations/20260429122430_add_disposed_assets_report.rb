class AddDisposedAssetsReport < ActiveRecord::DataMigration
  def up
    report_attributes = {
      report_type_id: 1,
      name: "Disposed Assets Report",
      description: "Reports Assets which have been disposed.",
      class_name: "DisposedAssetsReport",
      view_name: "grp_header_table_with_subreports",
      roles: "guest,user",
      custom_sql: nil,
      show_in_nav: true,
      show_in_dashboard: true,
      chart_type: nil,
      chart_options: nil,
      active: true,
      printable: true,
      exportable: true,
      data_exportable: nil
    }
    Report.create(report_attributes)
  end

  def down
    Report.find_by(class_name: "DisposedAssetsReport").destroy
  end
end