class AddRailSafetyFeatures < ActiveRecord::DataMigration
  def up
    [
        {name: 'Event Data Recorders', description: 'Report the total number of fleet vehicles equipped with event data recorders according to IEEE 1482.1 standard.', active: true},
        {name: 'Emergency Lighting', description: 'Report the total number of fleet vehicles with systems that meet the minimum performance criteria for emergency lighting specified by APTA RT-S-VIM-20-10 standard.', active: true},
        {name: 'Emergency Signage', description: 'Report the total number of fleet vehicles with systems that meet the minimum performance criteria for the design of emergency signage specified by APTA RT-S-VIM021-10 standard.', active: true},
        {name: 'Emergency Path Marking', description: 'Report the total number of fleet vehicles with systems that meet the minimum performance criteria for low-location exit path marking specified by APTA RT-S-VIM-022- 10 standard.', active: true}
    ].each do |safety_feature|
      RailSafetyFeature.create!(safety_feature)
    end
  end
end