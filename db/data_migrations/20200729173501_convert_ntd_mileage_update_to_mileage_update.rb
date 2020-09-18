class ConvertNtdMileageUpdateToMileageUpdate < ActiveRecord::DataMigration
  def up
    NtdMileageUpdateEvent.all.each do |ntd_event|
      asset = ntd_event.transam_asset

      event = asset.build_typed_event(MileageUpdateEvent)
      event.current_mileage = ntd_event.ntd_report_mileage
      event.event_date = ntd_event.event_date
      event.save!
      
      ntd_event.destroy
    end
  end
end
