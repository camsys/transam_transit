class UpdateFtaVehicleTypeNamesFeb2019 < ActiveRecord::DataMigration
  def up
    fta_vehicle_types = {
        "Ferry Boat" => "Ferryboat",
        "Mini Van" => "Minivan",
        "Monorail/Automated Guideway" => "Monorail Vehicle",
        "Over-The-Road Bus" => "Over-the-road Bus",
        "Rubber Tired Vintage Trolley" => "Rubber-tired Vintage Trolley",
        "Trolley Bus" => "Trolleybus",
        "Vintage Trolley/Streetcar" => "Vintage Trolley"
    }

    fta_vehicle_types.each do |old, new|
      FtaVehicleType.find_by(name: old).update(name: new, description: "#{new}.")
    end
  end
end