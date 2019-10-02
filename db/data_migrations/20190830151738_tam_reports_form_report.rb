class TamReportsFormReport < ActiveRecord::DataMigration
  def up
    Form.create!(
        name: "TAM Service Life Summary Report",
        description: "Reports on assets past service life",
        roles: "guest,user",
        controller: "tam_service_life_reports",
        sort_order: 0,
        active: true,

    )

    Report.find_by(class_name: "AssetTamPolicyServiceLifeReport").destroy!

  end
end