class AddSerialNumbertoServiceVehicles < ActiveRecord::DataMigration
  def up
    ServiceVehicle.all.each do |sv|
      unless sv.serial_numbers.first.nil?
        old_serial_number = sv.serial_numbers.first
        vin = old_serial_number.identification
        sv.serial_number = vin
        sv.save 
        old_serial_number.delete
      end
    end 
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