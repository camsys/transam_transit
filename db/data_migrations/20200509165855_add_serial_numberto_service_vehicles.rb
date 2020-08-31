class AddSerialNumbertoServiceVehicles < ActiveRecord::DataMigration
  def up
    unable_to_update = [] 
    ServiceVehicle.all.each do |sv|
      unless sv.serial_numbers.first.nil?
        old_serial_number = sv.serial_numbers.first
        vin = old_serial_number.identification
        sv.serial_number = vin
        begin
          sv.save 
          old_serial_number.delete
        rescue
          unabel_to_update << sv.id 
        end
      end
    end
    puts "Unable to update:"
    puts unable_to_update 
  end

  def down
    ServiceVehicle.all.each do |sv|
      old_serial_number = SerialNumber.new
      old_serial_number.identifiable_type = 'TransamAsset'
      old_serial_number.identifiable_id = sv.id 
      old_serial_number.identification = sv.serial_number
      old_serial_number.save 
    end 
  end
end