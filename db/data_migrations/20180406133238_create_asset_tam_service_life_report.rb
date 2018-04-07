class CreateAssetTamServiceLifeReport < ActiveRecord::DataMigration
  def up
    Report.create!({:active => 1, :report_type_id => ReportType.find_by(name:"Planning Report").id,
                    :name => 'TAM Service Life Summary Report',
                    :class_name => "AssetTamPolicyServiceLifeReport",
                    :view_name => "generic_table_with_subreports",
                    :show_in_nav => 1,
                    :show_in_dashboard => 0,
                    :roles => 'guest,user',
                    :description => 'Reports on assets past service life',
                    :printable => true,
                    :exportable => true,
                    :data_exportable => true,
                   }) unless Report.find_by(class_name: "AssetTamPolicyServiceLifeReport").present?
  end

  def down
    Report.find_by(class_name: "AssetTamPolicyServiceLifeReport").destroy!
  end
end