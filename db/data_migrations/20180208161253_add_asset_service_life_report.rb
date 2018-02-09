class AddAssetServiceLifeReport < ActiveRecord::DataMigration
  def up
    Report.create!({:active => 1, :report_type_id => ReportType.find_by(name:"Planning Report").id,
     :name => 'Asset Service Life Summary Report',
     :class_name => "AssetServiceLifeReport",
     :view_name => "generic_table_with_subreports",
     :show_in_nav => 1,
     :show_in_dashboard => 0,
     :roles => 'guest,user',
     :description => 'Reports on assets past service life',
     :printable => true,
     :exportable => true
    }) unless Report.find_by(class_name: "AssetServiceLifeReport").present?
  end

  def down
    Report.find_by(class_name: "AssetServiceLifeReport").destroy!
  end
end