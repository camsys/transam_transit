class DisableOldDispositionReport < ActiveRecord::DataMigration
  def up
    Report.find_by(class_name: "AssetDispositionReport")&.update(active: false)
  end

  def down
    Report.find_by(class_name: "AssetDispositionReport")&.update(active: true)
  end
end