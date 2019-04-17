class AddPerformanceRestrictionAssetEventType < ActiveRecord::DataMigration
  def up
    AssetEventType.create(name: 'Performance restrictions', class_name: 'PerformanceRestrictionUpdateEvent', job_name: '', display_icon_name: 'fa fa-tachometer', description: 'Performance Restriction Update', active: true)

    [
        {name: 'Maintenance', description: 'Maintenance', active: true},
        {name: 'Rail Defect', description: 'Rail Defect', active: true},
        {name: 'Signal, Controls Issue', description: 'Signal, Controls Issue', active: true},
        {name: 'Bridge Conditions', description: 'Bridge Conditions', active: true},
        {name: 'Track Geometry', description: 'Track Geometry', active: true},
        {name: 'Construction', description: 'Construction', active: true},
        {name: 'Weather', description: 'Weather', active: true},
        {name: 'Other', description: 'Other', active: true},
    ].each do |restriction_type|
      PerformanceRestrictionType.create(restriction_type)
    end
  end
end