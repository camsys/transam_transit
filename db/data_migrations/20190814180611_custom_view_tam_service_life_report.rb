class CustomViewTamServiceLifeReport < ActiveRecord::DataMigration
  def up
    Report.find_by(class_name: 'AssetTamPolicyServiceLifeReport').update!(view_name: 'asset_tam_service_life_report')
  end
end