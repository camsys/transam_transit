class AddCodeToFtaAssetClasses < ActiveRecord::DataMigration
  def up
    mapping = {
      "Buses (Rubber Tire Vehicles)": "bus", 
      "Rail Cars": "rail_car", 
      "Ferries": "ferry", 
      "Other Passenger Vehicles": "other_passenger_vehicle",
      "Service Vehicles (Non-Revenue)": "service_vehicle",
      "Capital Equipment": "captial_equipment",
      "Administration": "admin_facility",
      "Maintenance": "maintenance_facility",
      "Passenger": "passenger_facility",
      "Parking": "parking_facility",
      "Guideway": "guideway",
      "Power & Signal": "power_signal",
      "Track": "track"
     }
 
     FtaAssetClass.all.each do |c|
       puts "Updating #{c.name}. . . "
       c.code = mapping[c.name.to_sym]
       c.save
     end
  end
end