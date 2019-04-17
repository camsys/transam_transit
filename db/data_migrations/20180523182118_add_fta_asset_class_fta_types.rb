class AddFtaAssetClassFtaTypes < ActiveRecord::DataMigration
  def up
    FtaVehicleType.where(name:
      [
        "Articulated Bus",
        "Automobile",
        "Over-The-Road Bus",
        "Bus",
        "Cutaway",
        "Double Decker Bus",
        "Mini Van",
        "Minibus",
        "Rubber Tired Vintage Trolley",
        "School Bus",
        "Sports Utility Vehicle",
        "Trolley Bus",
        "Van",
        "Other"
      ]
    ).update_all(fta_asset_class_id: FtaAssetClass.find_by(name: 'Buses (Rubber Tire Vehicles)').id)

    FtaVehicleType.find_by(name: "Ferry Boat").update!(fta_asset_class_id: FtaAssetClass.find_by(name: 'Ferries').id)

    FtaVehicleType.where(name:
     [
         "Aerial Tramway",
         "Automated Guideway Vehicle",
         "Cable Car",
         "Inclined Plane Vehicle",
         "Monorail/Automated Guideway",
     ]
    ).update_all(fta_asset_class_id: FtaAssetClass.find_by(name: 'Other Passenger Vehicles').id)

    FtaVehicleType.where(name:
     [
         "Commuter Rail Locomotive",
         "Commuter Rail Passenger Coach",
         "Commuter Rail Self-Propelled Passenger Car",
         "Heavy Rail Passenger Car",
         "Light Rail Vehicle",
         "Streetcar",
         "Vintage Trolley/Streetcar"
     ]
    ).update_all(fta_asset_class_id: FtaAssetClass.find_by(name: 'Rail Cars').id)

    FtaFacilityType.where(name:
      [
          "Administrative Office/Sales Office",
          "Combined Administrative and Maintenance Facility",
          "Revenue Collection Facility",
          "Other, Administrative & Maintenance"
      ]
    ).update_all(fta_asset_class_id: FtaAssetClass.find_by(name: 'Administration').id)


    FtaFacilityType.where(name:
      [
         "At-Grade Fixed Guideway Station",
         "Bus Transfer Station",
         "Elevated Fixed Guideway Station",
         "Exclusive Grade-Separated Platform Station",
         "Other, Passenger or Parking",
         "Simple At-Grade Platform Station",
         "Underground Fixed Guideway Station"
      ]
    ).update_all(fta_asset_class_id: FtaAssetClass.find_by(name: 'Passenger').id)

    FtaFacilityType.where(name:
      [
        "Parking Structure",
        "Surface Parking Lot"
      ]
    ).update_all(fta_asset_class_id: FtaAssetClass.find_by(name: 'Parking').id)

    FtaFacilityType.where(name:
      [
         "General Purpose Maintenance Facility/Depot",
         "Heavy Maintenance and Overhaul (Backshop)",
         "Maintenance Facility (Service and Inspection)",
         "Vehicle Blow-Down Facility",
         "Vehicle Fueling Facility",
         "Vehicle Testing Facility",
         "Vehicle Washing Facility"
      ]
    ).update_all(fta_asset_class_id: FtaAssetClass.find_by(name: 'Maintenance').id)

    FtaSupportVehicleType.update_all(fta_asset_class_id: FtaAssetClass.find_by(name: 'Service Vehicles (Non-Revenue)').id)



  end
end