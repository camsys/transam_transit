FactoryGirl.define do
  sequence :asset_tag do |n|
    "CONCRETE_#{n}"
  end

  trait :basic_asset_attributes do
    association :organization, :factory => :transit_agency
    asset_tag
    purchased_new true
    purchase_date { 1.year.ago }
    purchase_cost 250000
    manufacture_year "2000"
    created_by_id 1
  end

  trait :vehicle_attributes do
    basic_asset_attributes
    fta_ownership_type_id 1 # TODO MAKE REAL
    fta_vehicle_type_id 2 # TODO MAKE REAL
    fta_funding_type_id 3 # TODO MAKE REAL
    expected_useful_life 15
    serial_number "1FMDU34E5XZ464008"
    title_owner_organization_id 1 # TODO
    manufacturer_id 1 # TODO
  end

  trait :structure_attributes do
    basic_asset_attributes
    expected_useful_life 25
    address1 "5000 Forbes Ave"
    city "Pittsburgh"
    state "PA"
    zip "15213"
    land_ownership_type_id 2 # TODO
    building_ownership_type_id 3 # TODO
    purchase_date { 5.years.ago }
    pcnt_operational 100
    fta_funding_type_id 1
    fta_facility_type_id 1
    section_of_larger_facility true
    ada_accessible_ramp true
    leed_certification_type_id 1
    num_parking_spaces_public 0
    num_parking_spaces_private 0
    pcnt_capital_responsibility 10
  end

  factory :bus, :class => :vehicle do
    vehicle_attributes
    asset_subtype { AssetSubtype.find_by(name: "Bus Std 40 FT") }
    asset_type    { asset_subtype.asset_type}
    seating_capacity 40
    standing_capacity 15
    wheelchair_capacity 3
    vehicle_length 40
    description "Bus Std 40 FT"
    manufacturer_model "TB"
    fuel_type_id 1 # TODO
    expected_useful_miles 250000
  end

  factory :buslike_asset, :class => :asset do # An untyped asset which looks like a bus
    vehicle_attributes
    asset_subtype { AssetSubtype.find_by(name: "Bus Std 40 FT") }
    asset_type    { asset_subtype.asset_type}
    standing_capacity 15
    wheelchair_capacity 3
    vehicle_length 40
    description "Bus Std 40 FT"
    manufacturer_model "TB"
    fuel_type_id 1 # TODO
    expected_useful_miles 250000
  end

  factory :light_rail_car, :class => :rail_car do
    vehicle_attributes
    asset_subtype { AssetSubtype.find_by(name: "Light Rail Car") }
    asset_type    { asset_subtype.asset_type }
    seating_capacity 65
    standing_capacity 25
    wheelchair_capacity 4
    vehicle_length 50
    description "Light Rail Car"
    manufacturer_model "TLRC"
  end

  factory :commuter_locomotive_diesel, :class => :locomotive do
    vehicle_attributes
    asset_subtype { AssetSubtype.find_by(name: "Commuter Locomotive Diesel") }
    asset_type    { asset_subtype.asset_type }
    description "Commuter Locomotive (Diesel)"
    manufacturer_model "TCLD"
  end

    factory :bus_shelter, :class => :transit_facility do
    structure_attributes
    asset_subtype { AssetSubtype.find_by(name: "Bus Shelter") }
    asset_type    { asset_subtype.asset_type }
    lot_size 30.0
    facility_size 25.0
    num_floors 1
    num_structures 1
    description "Bus Shelter"
  end

  factory :administration_building, :class => :support_facility do
    structure_attributes
    asset_subtype { AssetSubtype.find_by(name: "Administration Building") }
    asset_type    { asset_subtype.asset_type }
    lot_size 13000.0
    facility_size 10000.0
    num_floors 2
    num_structures 1
    facility_capacity_type_id 1 # TODO
    description "Administration Building"
  end

  factory :fixed_guideway, :class => :fixed_guideway do
    structure_attributes
    asset_subtype { AssetSubtype.find_by(name: "Administration Building") }
    asset_type    { asset_subtype.asset_type }
  end


end
