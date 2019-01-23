class AddFilterableClassNameToAudits < ActiveRecord::DataMigration
  def up
    if SystemConfig.transam_module_loaded? :audit
      Audit.where(auditor_class_name: "AssetAuditor").each do |audit|
        audit.filterable_class_name = "FtaAssetCategory"
        audit.save
      end
    end
  end
end