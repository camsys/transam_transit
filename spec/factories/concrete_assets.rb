FactoryGirl.define do
  sequence :asset_tag do |n|
    "CONCRETE_#{n}"
  end

  trait :basic_asset_attributes do
    association :organization, :factory => :transit_agency
    asset_tag
    purchase_date { 1.year.ago }
    manufacture_year "2000"
    created_by_id 1   
  end

  trait :vehicle_attributes do
    basic_asset_attributes
    fta_ownership_type_id 1 # TODO MAKE REAL
    fta_vehicle_type_id 2 # TODO MAKE REAL
    fta_funding_type_id 3 # TODO MAKE REAL
    fta_funding_source_type_id 3 # TODO MAKE REAL
    expected_useful_life 15
    pcnt_federal_funding 80
    vin "1FMDU34E5XZ464008"
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
    pcnt_federal_funding 80
    pcnt_operational 100
    fta_funding_type_id 1
    fta_funding_source_type_id 2
  end

  factory :bus, :class => :vehicle do
    vehicle_attributes
    asset_type_id 1
    asset_subtype_id 1
    seating_capacity 40
    standing_capacity 15
    wheelchair_capacity 3
    vehicle_length 40
    purchase_cost 250000
    description "Bus Std 40 FT"
    manufacturer_model "TB"
    fuel_type_id 1 # TODO
    expected_useful_miles 250000
  end

  factory :buslike_asset, :class => :asset do # An untyped asset which looks like a bus
    vehicle_attributes
    asset_type_id 1
    asset_subtype_id 1
    seating_capacity 40
    standing_capacity 15
    wheelchair_capacity 3
    vehicle_length 40
    purchase_cost 250000
    description "Bus Std 40 FT"
    manufacturer_model "TB"
    fuel_type_id 1 # TODO
    expected_useful_miles 250000
  end

  factory :light_rail_car, :class => :rail_car do
    vehicle_attributes
    asset_type_id 2
    asset_subtype_id 16
    seating_capacity 65
    standing_capacity 25
    wheelchair_capacity 4
    vehicle_length 50
    purchase_cost 500000
    description "Light Rail Car"
    manufacturer_model "TLRC"
  end

  factory :commuter_locomotive_diesel, :class => :locomotive do
    vehicle_attributes
    asset_type_id 3
    asset_subtype_id 23
    purchase_cost 500000
    description "Commuter Locomotive (Diesel)"
    manufacturer_model "TCLD"
  end

    factory :bus_shelter, :class => :transit_facility do
    structure_attributes
    asset_type_id 4
    asset_subtype_id 25
    lot_size 30.0
    facility_size 25.0
    purchase_cost 500000
    num_floors 1
    num_structures 1
    description "Bus Shelter"
  end

  factory :administration_building, :class => :support_facility do
    structure_attributes
    asset_type_id 5
    asset_subtype_id 35
    lot_size 13000.0
    facility_size 10000.0
    purchase_cost 500000
    num_floors 2
    num_structures 1
    facility_capacity_type_id 1 # TODO
    description "Administration Buidling"
  end


end