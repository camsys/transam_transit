class AddRailSafetyFeatures < ActiveRecord::DataMigration
  def up
    [
        {name: 'Event Data Recorders', description: 'Event Data Recorders', active: true},
        {name: 'Emergency Lighting', description: 'Emergency Lighting', active: true},
        {name: 'Emergency Signage', description: 'Emergency Signage', active: true},
        {name: 'Emergency Path Marking', description: 'Emergency Path Marking', active: true}
    ].each do |safety_feature|
      RailSafetyFeature.create!(safety_feature)
    end
  end
end