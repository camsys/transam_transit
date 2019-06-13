class AddNtdMileageUpdateEventType < ActiveRecord::DataMigration
  def up
    unless AssetEventType.find_by_class_name('NtdMileageUpdateEvent')
      AssetEventType.create!({
        :active => 1, 
        :name => 'NTD Mileage',       
        :display_icon_name => "fa fa-road",       
        :description => 'End of Year Odometer Reading for NTD A-30',       
        :class_name => 'NtdMileageUpdateEvent',
        :job_name => ''
        })
    end
  end
end