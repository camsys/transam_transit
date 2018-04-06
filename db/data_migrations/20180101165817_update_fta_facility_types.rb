class UpdateFtaFacilityTypes < ActiveRecord::DataMigration
  def up
    # update class names
    [["Maintenance Facility (Service and Inspection)", 'SupportFacility'],
     ["Heavy Maintenance and Overhaul (Backshop)", 'SupportFacility'],
     ["General Purpose Maintenance Facility/Depot", 'SupportFacility'],
     ["Vehicle Washing Facility", 'SupportFacility'],
     ["Vehicle Blow-Down Facility", 'SupportFacility'],
     ["Vehicle Fueling Facility", 'SupportFacility'],
     ["Vehicle Testing Facility", 'SupportFacility'],
     ["Administrative Office/Sales Office", 'SupportFacility'],
     ["Revenue Collection Facility", 'SupportFacility'],

     ["Bus Transfer Station", 'TransitFacility'],
     ["Elevated Fixed Guideway Station", 'TransitFacility'],
     ["At-Grade Fixed Guideway Station", 'TransitFacility'],
     ["Underground Fixed Guideway Station", 'TransitFacility'],
     ["Simple At-Grade Platform Station", 'TransitFacility'],
     ["Surface Parking Lot", 'TransitFacility'],
     ["Parking Structure", 'TransitFacility']
    ].each do |facility_type|
      FtaFacilityType.find_by(name: facility_type[0]).update!(class_name: facility_type[1]) if FtaFacilityType.find_by(name: facility_type[0])
    end

    # update names
    FtaFacilityType.find_by(name: 'Other Support Facility').update!(name: 'Other, Administrative & Maintenance', description: 'Other, Administrative & Maintenance.', class_name: 'SupportFacility') if FtaFacilityType.find_by(name: 'Other Support Facility')
    FtaFacilityType.find_by(name: 'Other Transit Facility').update!(name: 'Other, Passenger or Parking', description: 'Other, Passenger or Parking.', class_name: 'TransitFacility') if FtaFacilityType.find_by(name: 'Other Transit Facility')

    # add new types
    FtaFacilityType.create!(name: 'Combined Administrative and Maintenance Facility', description: 'Combined Administrative and Maintenance Facility.', class_name: 'SupportFacility', active: true) if FtaFacilityType.find_by(name: 'Combined Administrative and Maintenance Facility').nil?
    FtaFacilityType.create!(name: 'Exclusive Grade-Separated Platform Station', description: 'Exclusive Grade-Separated Platform Station.', class_name: 'TransitFacility', active: true) if FtaFacilityType.find_by(name: 'Exclusive Grade-Separated Platform Station').nil?

    # check that all transit facilities only have transit fta facility types and vice versa for support facilities
    TransitFacility.where(fta_facility_type_id: FtaFacilityType.where(class_name: 'SupportFacility').pluck(:id)).update_all(fta_facility_type_id: FtaFacilityType.find_by(name: 'Other, Passenger or Parking').id)
    SupportFacility.where(fta_facility_type_id: FtaFacilityType.where(class_name: 'TransitFacility').pluck(:id)).update_all(fta_facility_type_id: FtaFacilityType.find_by(name: 'Other, Administrative & Maintenance').id)

  end
end