#encoding: utf-8

# determine if we are using postgres or mysql
is_mysql = (ActiveRecord::Base.configurations[Rails.env]['adapter'].include? 'mysql2')
is_sqlite = (ActiveRecord::Base.configurations[Rails.env]['adapter'] == 'sqlite3')

puts "======= Processing TransAM Transit Lookup Tables  ======="

#------------------------------------------------------------------------------
#
# Customized Lookup Tables
#
# These are the specific to TransAM Transit
#
#------------------------------------------------------------------------------

forms = [
    {:active => 1,  :name => 'NTD Reporting Form', :roles => "guest,user,admin,manager,transit_manager", :controller => 'ntd_forms', :description => 'NTD Annual Reporting Forms.'},
    {name: "TAM Service Life Summary Report",
     description: "Reports on assets past service life",
     roles: "guest,user",
     controller: "tam_service_life_reports",
     sort_order: 0,
     active: true}
]

asset_fleet_types = [
    {
        class_name: "RevenueVehicle",
        groups:
            "transit_assets.fta_type_type, transit_assets.fta_type_id,revenue_vehicles.dedicated,transam_assets.manufacturer_id,transam_assets.other_manufacturer,transam_assets.manufacturer_model_id,transam_assets.other_manufacturer_model,transam_assets.manufacture_year,transam_assets.rebuilt_year,service_vehicles.fuel_type_id,service_vehicles.dual_fuel_type_id,revenue_vehicles.fta_ownership_type_id,revenue_vehicles.fta_funding_type_id,service_vehicles.vehicle_length,service_vehicles.vehicle_length_unit,service_vehicles.seating_capacity,revenue_vehicles.standing_capacity",
        custom_groups:
            "primary_fta_mode_type_id,secondary_fta_mode_type_id,direct_capital_responsibility,primary_fta_service_type_id,secondary_fta_service_type_id",
        label_groups: "primary_fta_mode_service,manufacturer,manufacture_year",
        active: true
    },
    {
        class_name: "ServiceVehicle",
        groups:
            "transit_assets.fta_type_type, transit_assets.fta_type_id,transam_assets.manufacture_year,transit_assets.pcnt_capital_responsibility",
        custom_groups: "primary_fta_mode_type_id,secondary_fta_mode_types",
        label_groups: "primary_fta_mode_type,manufacture_year",
        active: true
    }
]

asset_types = [
  {:active => 1, :name => 'Revenue Vehicles',       :description => 'Revenue rolling stock',      :class_name => 'Vehicle',           :map_icon_name => "redIcon",      :display_icon_name => "fa fa-bus"},
  {:active => 1, :name => 'Stations/Stops/Terminals', :description => 'Stations/Stops/Terminals', :class_name => 'TransitFacility',   :map_icon_name => "greenIcon",    :display_icon_name => "fa fa-building-o"},
  {:active => 1, :name => 'Support Facilities',     :description => 'Support Facilities',         :class_name => 'SupportFacility',   :map_icon_name => "blueIcon",     :display_icon_name => "fa fa-building"},
  {:active => 1, :name => 'Support Vehicles',       :description => 'Support Vehicles',           :class_name => 'SupportVehicle',    :map_icon_name => "blueIcon",     :display_icon_name => "fa fa-car"},

  {:active => 1, :name => 'Maintenance Equipment',    :description => 'Maintenance Equipment',      :class_name => 'Equipment',         :map_icon_name => "blueIcon",     :display_icon_name => "fa fa-wrench"},
  {:active => 1, :name => 'Facility Equipment',       :description => 'Facility Equipment',         :class_name => 'Equipment',         :map_icon_name => "blueIcon",     :display_icon_name => "fa fa-lightbulb-o"},
  {:active => 1, :name => 'IT Equipment',             :description => 'IT Equipment',               :class_name => 'Equipment',         :map_icon_name => "blueIcon",     :display_icon_name => "fa fa-laptop"},
  {:active => 1, :name => 'Office Equipment',         :description => 'Office Equipment',           :class_name => 'Equipment',         :map_icon_name => "blueIcon",     :display_icon_name => "fa fa-inbox"},
  {:active => 1, :name => 'Communications Equipment', :description => 'Communications Equipment',   :class_name => 'Equipment',         :map_icon_name => "blueIcon",     :display_icon_name => "fa fa-phone"},
  {:active => 1, :name => 'Signals/Signs',            :description => 'Signals and Signs',          :class_name => 'Equipment',         :map_icon_name => "blueIcon",     :display_icon_name => "fa fa-h-square"},

  {name: "Guideway", class_name: "Guideway", display_icon_name: "fa fa-map", map_icon_name: 'blueIcon', description: "Infrastructure placeholder asset type", allow_parent: false, active: true},
  {name: "Power & Signal", class_name: "PowerSignal", display_icon_name: "fa fa-plug", map_icon_name: 'blueIcon', description: "Infrastructure placeholder asset type", allow_parent: false, active: true},
  {name: "Track", class_name: "Track", display_icon_name: "fa fa-train", map_icon_name: 'blueIcon', description: "Infrastructure placeholder asset type", allow_parent: false, active: true},
]

asset_subtypes = [
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Revenue Vehicles', :name => 'Bus Std 40 FT',       :description => 'Bus Std 40 FT'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Revenue Vehicles', :name => 'Bus Std 35 FT',       :description => 'Bus Std 35 FT'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Revenue Vehicles', :name => 'Bus 30 FT',           :description => 'Bus 30 FT'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Revenue Vehicles', :name => 'Bus < 30 FT',         :description => 'Bus < 30 FT'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Revenue Vehicles', :name => 'Bus School',          :description => 'Bus School'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Revenue Vehicles', :name => 'Bus Articulated',     :description => 'Bus Articulated'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Revenue Vehicles', :name => 'Bus Commuter/Suburban',:description => 'Bus Commuter/Suburban'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Revenue Vehicles', :name => 'Bus Intercity',       :description => 'Bus Intercity'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Revenue Vehicles', :name => 'Bus Trolley Std',     :description => 'Bus Trolley Std'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Revenue Vehicles', :name => 'Bus Trolley Articulated',:description => 'Bus Trolley Articulated'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Revenue Vehicles', :name => 'Bus Double Deck',     :description => 'Bus Double Deck'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Revenue Vehicles', :name => 'Bus Dual Mode',       :description => 'Bus Dual Mode'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Revenue Vehicles', :name => 'Van',                 :description => 'Van'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Revenue Vehicles', :name => 'Sedan/Station Wagon', :description => 'Sedan/Station Wagon'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Revenue Vehicles', :name => 'Ferry Boat',          :description => 'Ferry Boat'},

  {:active => 1, :belongs_to => 'asset_type',  :type => 'Stations/Stops/Terminals', :name => 'Bus Shelter',           :description => 'Bus Shelter'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Stations/Stops/Terminals', :name => 'Bus Station',           :description => 'Bus Station'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Stations/Stops/Terminals', :name => 'Ferry Dock',            :description => 'Ferry Dock'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Stations/Stops/Terminals', :name => 'Intermodal Terminal',   :description => 'Intermodal Terminal'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Stations/Stops/Terminals', :name => 'Park and Ride Lot',     :description => 'Park and Ride Lot'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Stations/Stops/Terminals', :name => 'Parking Garage',        :description => 'Parking Garage'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Stations/Stops/Terminals', :name => 'Parking Lot',           :description => 'Parking Lot'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Stations/Stops/Terminals', :name => 'Other Transit Facility',:description => 'Other Transit Facility'},

  {:active => 1, :belongs_to => 'asset_type',  :type => 'Support Facilities', :name => 'Administration Building',   :description => 'Administration Building'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Support Facilities', :name => 'Bus Maintenance Facility',  :description => 'Bus Maintenance Facility'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Support Facilities', :name => 'Bus Parking Facility',      :description => 'Bus Parking Facility'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Support Facilities', :name => 'Bus Turnaround Facility',   :description => 'Bus Turnaround Facility'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Support Facilities', :name => 'Storage Yard',              :description => 'Storage Yard'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Support Facilities', :name => 'Other Support Facility',    :description => 'Other Support Facility'},

  {:active => 1, :belongs_to => 'asset_type',  :type => 'Support Vehicles',  :name => 'Van',                    :description => 'Van'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Support Vehicles',  :name => 'Tow Truck',              :description => 'Tow Truck'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Support Vehicles',  :name => 'Sedan/Station Wagon',    :description => 'Sedan/Station Wagon'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Support Vehicles',  :name => 'Pickup/Utility Truck',   :description => 'Pickup/Utility Truck'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Support Vehicles',  :name => 'Sports Utility Vehicle', :description => 'Sports Utility Vehicle'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Support Vehicles',  :name => 'Other Support Vehicle',  :description => 'Other Support Vehicle'},

  {:active => 1, :belongs_to => 'asset_type',  :type => 'Maintenance Equipment',  :name => 'Bus Maintenance Equipment',   :description => 'Bus Maintenance Equipment'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Maintenance Equipment',  :name => 'Other Maintenance Equipment', :description => 'Other Maintenance Equipment'},

  {:active => 1, :belongs_to => 'asset_type',  :type => 'Facility Equipment',  :name => 'Mechanical Equipment',       :description => 'Mechanical Equipment'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Facility Equipment',  :name => 'Electrical Equipment',       :description => 'Electrical Equipment'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Facility Equipment',  :name => 'Structural Equipment',       :description => 'Structural Equipment'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Facility Equipment',  :name => 'Other Facilities Equipment', :description => 'Other Facilities Equipment'},

  {:active => 1, :belongs_to => 'asset_type',  :type => 'IT Equipment',  :name => 'Hardware',           :description => 'Hardware'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'IT Equipment',  :name => 'Software',           :description => 'Hardware'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'IT Equipment',  :name => 'Networks',           :description => 'Hardware'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'IT Equipment',  :name => 'Storage',            :description => 'Storage'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'IT Equipment',  :name => 'Other IT Equipment', :description => 'Hardware'},

  {:active => 1, :belongs_to => 'asset_type',  :type => 'Office Equipment',  :name => 'Furniture',              :description => 'Office Furniture'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Office Equipment',  :name => 'Supplies',               :description => 'Office Supplies'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Office Equipment',  :name => 'Other Office Equipment', :description => 'Other Office Equipment'},

  {:active => 1, :belongs_to => 'asset_type',  :type => 'Communications Equipment',  :name => 'Vehicle Location Systems',   :description => 'Vehicle Location Systems'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Communications Equipment',  :name => 'Radios',                     :description => 'Radios'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Communications Equipment',  :name => 'Surveillance & Security',    :description => 'Surveillance & Security'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Communications Equipment',  :name => 'Fare Collection Systems',    :description => 'Fare Collection Systems'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Communications Equipment',  :name => 'Other Communications Equipment', :description => 'Other Communication Equipment'},

  {:active => 1, :belongs_to => 'asset_type',  :type => 'Signals/Signs',  :name => 'Route Signage',            :description => 'Route Signage'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Signals/Signs',  :name => 'Other Signage Equipment',  :description => 'Other Signage Equipment'},

  {:active => 1, :belongs_to => 'asset_type',  :type => 'Track',  :name => 'Tangent (Straight)',  :description => 'Tangent (Straight)'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Track',  :name => 'Curve',  :description => 'Curve'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Track',  :name => 'Transition Curve',  :description => 'Transition Curve'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Track',  :name => 'Special Work Asset',  :description => 'Special Work Asset'},

  {:active => 1, :belongs_to => 'asset_type',  :type => 'Guideway',  :name => 'At-Grade',  :description => 'At-Grade'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Guideway',  :name => 'At-Grade - Crossing',  :description => 'At-Grade - Crossing'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Guideway',  :name => 'Bridge',  :description => 'Bridge'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Guideway',  :name => 'Tunnel',  :description => 'Tunnel'},

  {:active => 1, :belongs_to => 'asset_type',  :type => 'Power & Signal',  :name => 'Signal Equipment',  :description => 'Signal Equipment'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Power & Signal',  :name => 'Signal System',  :description => 'Signal System'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Power & Signal',  :name => 'Substation',  :description => 'Substation'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Power & Signal',  :name => 'Power Equipment',  :description => 'Power Equipment'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Power & Signal',  :name => 'Drive System',  :description => 'Drive System'},
  {:active => 1, :belongs_to => 'asset_type',  :type => 'Power & Signal',  :name => 'Distribution',  :description => 'Distribution'},
]

fuel_types = [
  {:active => 1, :name => 'Biodiesel',                      :code => 'BD', :description => 'Biodiesel.'},
  {:active => 1, :name => 'Bunker Fuel',                    :code => 'BF', :description => 'Bunker Fuel.'},
  {:active => 1, :name => 'Compressed Natural Gas',         :code => 'CNG', :description => 'Compressed Natutral Gas.'},
  {:active => 1, :name => 'Diesel Fuel',                    :code => 'DF', :description => 'Diesel Fuel.'},
  {:active => 1, :name => 'Dual Fuel',                      :code => 'DU', :description => 'Dual Fuel.'},
  {:active => 1, :name => 'Electric Battery',               :code => 'EB', :description => 'Electric Battery.'},
  {:active => 1, :name => 'Electric Propulsion Power',            :code => 'EP', :description => 'Electric Propulsion.'},
  {:active => 1, :name => 'Ethanol',                        :code => 'ET', :description => 'Ethanol.'},
  {:active => 1, :name => 'Gasoline',                       :code => 'GA', :description => 'Gasoline.'},
  {:active => 1, :name => 'Hybrid Diesel',                  :code => 'HD', :description => 'Hybrid Diesel.'},
  {:active => 1, :name => 'Hybrid Gasoline',                :code => 'HG', :description => 'Hybrid Gasoline.'},
  {:active => 1, :name => 'Hydrogen Cell',                       :code => 'HY', :description => 'Hydrogen.'},
  {:active => 1, :name => 'Kerosene',                       :code => 'KE', :description => 'Kerosene.'},
  {:active => 1, :name => 'Liquefied Natural Gas',          :code => 'LN', :description => 'Liquefied Natural Gas.'},
  {:active => 1, :name => 'Liquefied Petroleum Gas',        :code => 'LP', :description => 'Liquefied Petroleum Gas.'},
  {:active => 1, :name => 'Methanol',                       :code => 'MT', :description => 'Methanol.'},
  {:active => 0, :name => 'Used/Recycled Cooking Oil',      :code => 'CK', :description => 'Used/Recycled Cooking Oil.'},
  {:active => 1, :name => 'Other',                          :code => 'OR', :description => 'Other.'},
]

rail_safety_features = [
    {name: 'Event Data Recorders', description: 'Report the total number of fleet vehicles equipped with event data recorders according to IEEE 1482.1 standard.', active: true},
    {name: 'Emergency Lighting', description: 'Report the total number of fleet vehicles with systems that meet the minimum performance criteria for emergency lighting specified by APTA RT-S-VIM-20-10 standard.', active: true},
    {name: 'Emergency Signage', description: 'Report the total number of fleet vehicles with systems that meet the minimum performance criteria for the design of emergency signage specified by APTA RT-S-VIM021-10 standard.', active: true},
    {name: 'Emergency Path Marking', description: 'Report the total number of fleet vehicles with systems that meet the minimum performance criteria for low-location exit path marking specified by APTA RT-S-VIM-022- 10 standard.', active: true}
]

vehicle_features = [
  {:active => 1, :name => 'AVL System',           :code => 'AS', :description => 'Automatic Vehicle Location System.'},
  {:active => 1, :name => 'Lift Equipped',        :code => 'LE', :description => 'Lift Equipped.'},
  {:active => 1, :name => 'Electronic Ramp',      :code => 'ER', :description => 'Electronic Ramp.'},
  {:active => 1, :name => 'Video Cameras',        :code => 'VC', :description => 'Video Cameras.'},
  {:active => 1, :name => 'Fare Box (Standard)',  :code => 'FBS', :description => 'Fare Box (Standard).'},
  {:active => 1, :name => 'Fare Box (Electronic)',:code => 'FBE', :description => 'Fare Box (Electronic).'},
  {:active => 1, :name => 'Radio Equipped',       :code => 'RE', :description => 'Radio Equipped.'},
  {:active => 1, :name => 'Bike Rack',            :code => 'BR', :description => 'Bike Rack.'},
  {:active => 1, :name => 'Scheduling Software',  :code => 'SS', :description => 'Scheduling Software.'},
  {:active => 1, :name => 'WIFI',                 :code => 'WI', :description => 'WIFI.'}
]
vehicle_usage_codes = [
  {:active => 1, :name => 'Revenue Vehicle',  :code => 'R', :description => 'Revenue Vehicle.'},
  {:active => 1, :name => 'Support Vehicle',  :code => 'S', :description => 'Support Vehicle.'},
  {:active => 1, :name => 'Van Pool',         :code => 'V', :description => 'Van Pool.'},
  {:active => 1, :name => 'Paratransit',      :code => 'P', :description => 'Paratransit.'},
  {:active => 1, :name => 'Spare Inventory',  :code => 'I', :description => 'Spare Inventory.'},
  {:active => 1, :name => 'Unknown',          :code => 'X', :description => 'No vehicle usage specified.'}
]

vehicle_rebuild_types = [
  {:active => 1, :name => 'Mid-Life Overhaul',        :description => 'Mid-Life Overhaul'},
  {:active => 1, :name => 'Life-Extending Overhaul',  :description => 'Life-Extending Overhaul'},
]

fta_mode_types = [
    {code: 'HR', name: 'Heavy Rail', description: 'Heavy Rail', active: true},
    {code: 'CR', name: 'Commuter Rail', description: 'Commuter Rail', active: true},
    {code: 'LR', name: 'Light Rail', description: 'Light Rail', active: true},
    {code: 'SR', name: 'Streetcar Rail', description: 'Streetcar Rail', active: true},
    {code: 'MG', name: 'Monorail/Automated Guideway', description: 'Monorail/Automated Guideway', active: true},
    {code: 'CC', name: 'Cable Car', description: 'Cable Car', active: true},
    {code: 'YR', name: 'Hybrid Rail', description: 'Hybrid Rail', active: true},
    {code: 'IP', name: 'Inclined Plane', description: 'Inclined Plane', active: true},
    {code: 'AR', name: 'Alaska Railroad', description: 'Alaska Railroad', active: true},
    {code: 'MB', name: 'Bus', description: 'Bus', active: true},
    {code: 'DR', name: 'Demand Response', description: 'Demand Response', active: true},
    {code: 'TB', name: 'Trolleybus', description: 'Trolleybus', active: true},
    {code: 'CB', name: 'Commuter Bus', description: 'Commuter Bus', active: true},
    {code: 'FB', name: 'Ferryboat', description: 'Ferryboat', active: true},
    {code: 'RB', name: 'Bus Rapid Transit', description: 'Bus Rapid Transit', active: true},
    {code: 'VP', name: 'Vanpool', description: 'Vanpool', active: true},
    {code: 'PB', name: 'Publico', description: 'Publico', active: true},
    {code: 'DT', name: 'Demand Response Taxi', description: 'Demand Response Taxi', active: true},
    {code: 'TR', name: 'Aerial Tramway', description: 'Aerial Tramway', active: true},
    {code: 'JT', name: 'Jitney', description: 'Jitney', active: true},
    {code: 'OR', name: 'Other Vehicles Operated', description: 'Other Vehicles Operated.', active: true},
    {code: 'XX', name: 'Unknown', description: 'Unknown', active: false}
]
fta_private_mode_types = [
    {active: 1, name: 'Shared With Non-Public Mode: Airport, Private Bus Transit', description: 'Shared With Non-Public Mode: Airport, Private Bus Transit'},
    {active: 1, name: 'Shared With Non-Public Mode: Private Rail Transit', description: 'Shared With Non-Public Mode: Private Rail Transit'},
    {active: 1, name: 'Shared With Non-Public Mode: Private Water Transit', description: 'Shared With Non-Public Mode: Private Water Transit'}
]
fta_bus_mode_types = [
  # Rural Reporting Modes
  {:active => 1, :name => 'Deviated Fixed Route', :code => 'DFR', :description => 'Deviated Fixed Route'},
  {:active => 1, :name => 'Fixed Route',          :code => 'FR', :description => 'Fixed route'},
  {:active => 1, :name => 'Both',                 :code => 'B', :description => 'Both deviated and fixed routes.'},
]
fta_service_types = [
  {:active => 1, :name => 'Directly Operated',            :code => 'DO', :description => 'Directly Operated.'},
  {:active => 1, :name => 'Purchased Transportation',     :code => 'PT', :description => 'Purchased Transportation.'},
  {:active => 0, :name => 'Unknown',                      :code => 'XX', :description => 'FTA Service type not specified.'}
]

fta_agency_types = [
  {:active => 1, :name => 'Public Agency (Not DOT or Tribal)',      :description => 'Public Agency (Not DOT or Tribal).'},
  {:active => 1, :name => 'Public Agency (State DOT)',    :description => 'Public Agency (State DOT).'},
  {:active => 1, :name => 'Public Agency (Tribal)',       :description => 'Public Agency (Tribal).'},
  {:active => 1, :name => 'Private (Not for profit)',     :description => 'Private (Not for profit).'}
]
fta_service_area_types = [
  {:active => 1, :name => 'County/Independent city',          :description => 'County / Independent city.'},
  {:active => 1, :name => 'Multi-county/Independent city',    :description => 'Multi-county / Independent city.'},
  {:active => 1, :name => 'Multi-state',                      :description => 'Multi-state.'},
  {:active => 1, :name => 'Municipality',                     :description => 'Municipality.'},
  {:active => 1, :name => 'Reservation',                      :description => 'Reservation.'},
  {:active => 1, :name => 'Other',                            :description => 'Other.'}
]

fta_funding_types = [
  {:active => 1, :name => 'Urbanized Area Formula Program', :code => 'UA',    :description => 'UA -Urbanized Area Formula Program.'},
  {:active => 1, :name => 'Other Federal funds',            :code => 'OF',    :description => 'OF-Other Federal funds.'},
  {:active => 1, :name => 'Non-Federal public funds',       :code => 'NFPA',  :description => 'NFPA-Non-Federal public funds.'},
  {:active => 1, :name => 'Non-Federal private funds',      :code => 'NFPE',  :description => 'NFPE-Non-Federal private funds.'},
  {:active => 1, :name => 'Rural Area Formula Program',     :code => 'RAFP',  :description => 'Rural Area Formula Program.'},
  {:active => 1, :name => 'Enhanced Mobility for Seniors and Individuals with Disabilities',      :code => 'EMSID',  :description => 'Enhanced Mobility for Seniors and Individuals with Disabilities.'},
  {:active => 0, :name => 'Unknown',                        :code => 'XX',    :description => 'FTA funding type not specified.'}
]
fta_ownership_types = [
  # Rural Reporting Ownership Types
  {:active => 1, :name => 'Owned outright by private entity',                             :code => 'OOPE',  :description => 'Owned outright by private entity.'},
  {:active => 1, :name => 'Owned outright by public agency',                              :code => 'OOPA',  :description => 'Owned outright by public agency.'},
  {:active => 1, :name => 'True lease by private entity',                                 :code => 'TLPE',  :description => 'True lease by private entity.'},
  {:active => 1, :name => 'True lease by public agency',                                  :code => 'TLPA',  :description => 'True lease by public agency.'},
  {:active => 1, :name => 'Other',                                                        :code => 'OTHR',  :description => 'Other.'},
  {:active => 1, :name => 'Leased or borrowed from related parties by a public agency',   :code => 'LRPA',  :description => 'Leased or borrowed from related parties by a public agency.'},
  {:active => 1, :name => 'Leased or borrowed from related parties by a private entity',  :code => 'LRPE',  :description => 'Leased or borrowed from related parties by a private entity.'},
  {:active => 1, :name => 'Leased under lease purchase agreement by a public agency',     :code => 'LPPA',  :description => 'Leased under lease purchase agreement by a private entity.'},
  {:active => 1, :name => 'Leased under lease purchase agreement by a private entity',    :code => 'LPPE',  :description => 'Leased under lease purchase agreement by a private entity.'}
]

fta_vehicle_types = [
  # Rural Reporting Types
  {:active => 1, :name => 'Automobile',             :code => 'AO',  :description => 'Automobile.', :default_useful_life_benchmark => 8, :useful_life_benchmark_unit => 'year', :fta_asset_class => 'Buses (Rubber Tire Vehicles)'},
  {:active => 1, :name => 'Bus',                    :code => 'BU',  :description => 'Bus.', :default_useful_life_benchmark => 14, :useful_life_benchmark_unit => 'year', :fta_asset_class => 'Buses (Rubber Tire Vehicles)'},
  {:active => 1, :name => 'Cutaway',                :code => 'CU',  :description => 'Cutaway.', :default_useful_life_benchmark => 10, :useful_life_benchmark_unit => 'year', :fta_asset_class => 'Buses (Rubber Tire Vehicles)'},
  {:active => 1, :name => 'Ferryboat',              :code => 'FB',  :description => 'Ferryboat.', :default_useful_life_benchmark => 42, :useful_life_benchmark_unit => 'year', :fta_asset_class => 'Ferries'},
  {:active => 1, :name => 'Minivan',                :code => 'MV',  :description => 'Minivan.', :default_useful_life_benchmark => 8, :useful_life_benchmark_unit => 'year', :fta_asset_class => 'Buses (Rubber Tire Vehicles)'},
  {:active => 1, :name => 'Over-the-road Bus',      :code => 'BR',  :description => 'Over-the-road Bus.', :default_useful_life_benchmark => 14, :useful_life_benchmark_unit => 'year', :fta_asset_class => 'Buses (Rubber Tire Vehicles)'},
  {:active => 1, :name => 'School Bus',             :code => 'SB',  :description => 'School Bus.', :default_useful_life_benchmark => 14, :useful_life_benchmark_unit => 'year', :fta_asset_class => 'Buses (Rubber Tire Vehicles)'},
  {:active => 1, :name => 'Sports Utility Vehicle', :code => 'SV',  :description => 'Sports Utility Vehicle.', :default_useful_life_benchmark => 8, :useful_life_benchmark_unit => 'year', :fta_asset_class => 'Buses (Rubber Tire Vehicles)'},
  {:active => 1, :name => 'Van',                    :code => 'VN',  :description => 'Van.', :default_useful_life_benchmark => 8, :useful_life_benchmark_unit => 'year', :fta_asset_class => 'Buses (Rubber Tire Vehicles)'},
  {:active => 1, :name => 'Articulated Bus',        :code => 'AB',  :description => 'Articulated Bus.', :default_useful_life_benchmark => 14, :useful_life_benchmark_unit => 'year', :fta_asset_class => 'Buses (Rubber Tire Vehicles)'},
  {:active => 1, :name => 'Double Decker Bus',      :code => 'DB',  :description => 'Double Decker Bus.', :default_useful_life_benchmark => 14, :useful_life_benchmark_unit => 'year', :fta_asset_class => 'Buses (Rubber Tire Vehicles)'},
  {:active => 1, :name => 'Aerial Tramway',         :code => 'TR',  :description => 'Aerial Tramway.', :default_useful_life_benchmark => 12, :useful_life_benchmark_unit => 'year', :fta_asset_class => 'Other Passenger Vehicles'},

  # Urban Reporting Types
  {:active => 1, :name => 'Automated Guideway Vehicle',        :code => 'AG',  :description => 'Automated Guideway Vehicle.', :default_useful_life_benchmark => 31, :useful_life_benchmark_unit => 'year', :fta_asset_class => 'Other Passenger Vehicles'},
  {:active => 1, :name => 'Cable Car',              :code => 'CC',  :description => 'Cable Car.', :default_useful_life_benchmark => 112, :useful_life_benchmark_unit => 'year', :fta_asset_class => 'Other Passenger Vehicles'},
  {:active => 1, :name => 'Heavy Rail Passenger Car',  :code => 'HR',  :description => 'Heavy Rail Passenger Car.', :default_useful_life_benchmark => 31, :useful_life_benchmark_unit => 'year', :fta_asset_class => 'Rail Cars'},
  {:active => 1, :name => 'Inclined Plane Vehicle', :code => 'IP',  :description => 'Inclined Plane Vehicle.', :default_useful_life_benchmark => 56, :useful_life_benchmark_unit => 'year', :fta_asset_class => 'Other Passenger Vehicles'},
  {:active => 1, :name => 'Light Rail Vehicle', :code => 'LR',  :description => 'Light Rail Vehicle.', :default_useful_life_benchmark => 31, :useful_life_benchmark_unit => 'year', :fta_asset_class => 'Rail Cars'},
  {:active => 1, :name => 'Monorail Vehicle', :code => 'MO',  :description => 'Monorail Vehicle.', :default_useful_life_benchmark => 31, :useful_life_benchmark_unit => 'year', :fta_asset_class => 'Other Passenger Vehicles'},
  {:active => 1, :name => 'Commuter Rail Locomotive',                   :code => 'RL',  :description => 'Commuter Rail Locomotive.', :default_useful_life_benchmark => 39, :useful_life_benchmark_unit => 'year', :fta_asset_class => 'Rail Cars'},
  {:active => 1, :name => 'Commuter Rail Passenger Coach',              :code => 'RP',  :description => 'Commuter Rail Passenger Coach.', :default_useful_life_benchmark => 39, :useful_life_benchmark_unit => 'year', :fta_asset_class => 'Rail Cars'},
  {:active => 1, :name => 'Commuter Rail Self-Propelled Passenger Car', :code => 'RS',  :description => 'Commuter Rail Self-Propelled Passenger Car.', :default_useful_life_benchmark => 39, :useful_life_benchmark_unit => 'year', :fta_asset_class => 'Rail Cars'},
  {:active => 1, :name => 'Trolleybus',            :code => 'TB',  :description => 'Trolleybus.', :default_useful_life_benchmark => 13, :useful_life_benchmark_unit => 'year', :fta_asset_class => 'Buses (Rubber Tire Vehicles)'},
  {:active => 1, :name => 'Streetcar',:code => 'SR',  :description => 'Streetcar.', :default_useful_life_benchmark => 31, :useful_life_benchmark_unit => 'year', :fta_asset_class => 'Rail Cars'},
  {:active => 1, :name => 'Vintage Trolley',:code => 'VT',  :description => 'Vintage Trolley.', :default_useful_life_benchmark => 58, :useful_life_benchmark_unit => 'year', :fta_asset_class => 'Rail Cars'},

  {:active => 1, :name => 'Other',                :code => 'OR', :description => 'Other.', :fta_asset_class => 'Buses (Rubber Tire Vehicles)'}

]

fta_support_vehicle_types = [
    {name: 'Automobiles', description: 'Automobiles', active: true, default_useful_life_benchmark: 8, useful_life_benchmark_unit: 'year', :fta_asset_class => 'Service Vehicles (Non-Revenue)'},
    {name: 'Trucks and other Rubber Tire Vehicles', description: 'Trucks and other Rubber Tire Vehicles', active: true, default_useful_life_benchmark: 14, useful_life_benchmark_unit: 'year', :fta_asset_class => 'Service Vehicles (Non-Revenue)'},
    {name: 'Steel Wheel Vehicles', description: 'Steel Wheel Vehicles', active: true, default_useful_life_benchmark: 25, useful_life_benchmark_unit: 'year', :fta_asset_class => 'Service Vehicles (Non-Revenue)'},
    {name: 'Unknown', description: 'Unknown', active: false, :fta_asset_class => 'Service Vehicles (Non-Revenue)'}
]

fta_facility_types = [
    # Facility Types for Support Facilities
    {:active => 1, :class_name => 'SupportFacility', :name => 'Maintenance Facility (Service and Inspection)',     :description => 'Maintenance Facility (Service and Inspection).', :fta_asset_class => 'Maintenance'},
    {:active => 1, :class_name => 'SupportFacility', :name => 'Heavy Maintenance and Overhaul (Backshop)',    :description => 'Heavy Maintenance and Overhaul (Backshop).', :fta_asset_class => 'Maintenance'},
    {:active => 1, :class_name => 'SupportFacility', :name => 'General Purpose Maintenance Facility/Depot',       :description => 'General Purpose Maintenance Facility/Depot.', :fta_asset_class => 'Maintenance'},
    {:active => 1, :class_name => 'SupportFacility', :name => 'Vehicle Washing Facility',     :description => 'Vehicle Washing Facility.', :fta_asset_class => 'Maintenance'},
    {:active => 1, :class_name => 'SupportFacility', :name => 'Vehicle Blow-Down Facility',     :description => 'Vehicle Blow-Down Facility.', :fta_asset_class => 'Maintenance'},
    {:active => 1, :class_name => 'SupportFacility', :name => 'Vehicle Fueling Facility',     :description => 'Vehicle Fueling Facility.', :fta_asset_class => 'Maintenance'},
    {:active => 1, :class_name => 'SupportFacility', :name => 'Vehicle Testing Facility',     :description => 'Vehicle Testing Facility.', :fta_asset_class => 'Maintenance'},
    {:active => 1, :class_name => 'SupportFacility', :name => 'Administrative Office / Sales Office',     :description => 'Administrative Office/Sales Office.', :fta_asset_class => 'Administration'},
    {:active => 1, :class_name => 'SupportFacility', :name => 'Revenue Collection Facility',     :description => 'Revenue Collection Facility.', :fta_asset_class => 'Administration'},
    {:active => 1, :class_name => 'SupportFacility', :name => 'Combined Administrative and Maintenance Facility',     :description => 'Combined Administrative and Maintenance Facility.', :fta_asset_class => 'Administration'},
    {:active => 1, :class_name => 'SupportFacility', :name => 'Other, Administrative & Maintenance',     :description => 'Other, Administrative & Maintenance.', :fta_asset_class => 'Administration'},
    # Facility Types for Transit Facilities
    {:active => 1, :class_name => 'TransitFacility', :name => 'Bus Transfer Station',     :description => 'Bus Transfer Station.', :fta_asset_class => 'Passenger'},
    {:active => 1, :class_name => 'TransitFacility', :name => 'Elevated Fixed Guideway Station',    :description => 'Elevated Fixed Guideway Station.', :fta_asset_class => 'Passenger'},
    {:active => 1, :class_name => 'TransitFacility', :name => 'At-Grade Fixed Guideway Station',       :description => 'At-Grade Fixed Guideway Station.', :fta_asset_class => 'Passenger'},
    {:active => 1, :class_name => 'TransitFacility', :name => 'Underground Fixed Guideway Station',     :description => 'Underground Fixed Guideway Station.', :fta_asset_class => 'Passenger'},
    {:active => 1, :class_name => 'TransitFacility', :name => 'Simple At-Grade Platform Station',     :description => 'Simple At-Grade Platform Station.', :fta_asset_class => 'Passenger'},
    {:active => 1, :class_name => 'TransitFacility', :name => 'Surface Parking Lot',     :description => 'Surface Parking Lot.', :fta_asset_class => 'Parking'},
    {:active => 1, :class_name => 'TransitFacility', :name => 'Parking Structure',     :description => 'Parking Structure.', :fta_asset_class => 'Parking'},
    {:active => 1, :class_name => 'TransitFacility', :name => 'Exclusive Grade-Separated Platform Station',     :description => 'Exclusive Grade-Separated Platform Station.', :fta_asset_class => 'Passenger'},
    {:active => 1, :class_name => 'TransitFacility', :name => 'Other, Passenger or Parking',     :description => 'Other, Passenger or Parking.', :fta_asset_class => 'Passenger'},
    {:active => 1, :class_name => 'TransitFacility', :name => 'Ferryboat Terminal',     :description => 'Ferryboat Terminal.', :fta_asset_class => 'Passenger'}
]

fta_equipment_types = [
    {name: 'Fare Equipment', fta_asset_class: 'Capital Equipment', active: true},
    {name: 'Maintenance Equipment', fta_asset_class: 'Capital Equipment', active: true},
    {name: 'Facility Equipment', fta_asset_class: 'Capital Equipment', active: true},
    {name: 'IT Equipment', fta_asset_class: 'Capital Equipment', active: true},
    {name: 'Office Equipment', fta_asset_class: 'Capital Equipment', active: true},
    {name: 'Communications Equipment', fta_asset_class: 'Capital Equipment', active: true},
    {name: 'Security/Surveillance Equipment', fta_asset_class: 'Capital Equipment', active: true},
    {name: 'Bus Shelter', fta_asset_class: 'Capital Equipment', active: true},
    {name: 'Signage', fta_asset_class: 'Capital Equipment', active: true},
    {name: 'Passenger Amenities', fta_asset_class: 'Capital Equipment', active: true},
    {name: 'Lanscaping/Public Art', fta_asset_class: 'Capital Equipment', active: true},
    {name: 'Electrification / Power Distribution', fta_asset_class: 'Capital Equipment', active: true},
    {name: 'Miscellaneous', fta_asset_class: 'Capital Equipment', active: true},
]

facility_capacity_types = [
  {:active => 1, :name => 'N/A',                             :description => 'Not applicable.'},
  {:active => 1, :name => 'Less than 200 vehicles',          :description => 'Less than 200 vehicles.'},
  {:active => 1, :name => 'Between 200 and 300 vehicles',    :description => 'Between 200 and 300 vehicles.'},
  {:active => 1, :name => 'Over 300 vehicles',               :description => 'Over 300 vehicles.'}
]
facility_features = [
  {:active => 1, :name => 'Moving walkways',    :code => 'MW', :description => 'Moving walkways.'},
  {:active => 1, :name => 'Ticketing',          :code => 'TK', :description => 'Ticketing.'},
  {:active => 1, :name => 'Information kiosks', :code => 'IK', :description => 'Information kiosks.'},
  {:active => 1, :name => 'Restrooms',          :code => 'RR', :description => 'Restrooms.'},
  {:active => 1, :name => 'Concessions',        :code => 'CS', :description => 'Concessions.'},
  {:active => 1, :name => 'Telephones',         :code => 'TP', :description => 'Telephones.'},
  {:active => 1, :name => 'ATM',                :code => 'AT', :description => 'ATM.'},
  {:active => 1, :name => 'WIFI',               :code => 'WI', :description => 'WIFI.'}
]

leed_certification_types = [
  {:active => 1, :name => 'Not Certified',  :description => 'Not Certified'},
  {:active => 1, :name => 'Certified',  :description => 'Certified'},
  {:active => 1, :name => 'Silver',  :description => 'Silver'},
  {:active => 1, :name => 'Gold',  :description => 'Gold'},
  {:active => 1, :name => 'Platinum',  :description => 'Platinum'},
]

district_types = [
  {:active => 1, :name => 'State',        :description => 'State.'},
  {:active => 1, :name => 'District',     :description => 'Engineering District.'},
  {:active => 1, :name => 'MSA',          :description => 'Metropolitan Statistical Area.'},
  {:active => 1, :name => 'County',       :description => 'County.'},
  {:active => 1, :name => 'City',         :description => 'City.'},
  {:active => 1, :name => 'Borough',      :description => 'Borough.'},
  {:active => 1, :name => 'MPO/RPO',      :description => 'MPO or RPO planning area.'},
  {:active => 1, :name => 'Postal Code',  :description => 'ZIP Code or Postal Area.'},
  {:active => 1, :name => 'UZA',          :description => 'Urbanized Area.'},
  {:active => 1, :name => 'House',          :description => 'House Congressional District.'},
  {:active => 1, :name => 'Senate',          :description => 'Senate Congressional District.'},
  {:active => 1, :name => 'Federal',          :description => 'Federal Congressional District.'}
]

file_content_types = [
  {:active => 1, :name => 'Inventory Updates',    :class_name => 'TransitInventoryUpdatesFileHandler',  :builder_name => "TransitInventoryUpdatesTemplateBuilder",    :description => 'Worksheet records updated condition, status, and mileage for existing inventory.'},
  {:active => 1, :name => 'Maintenance Updates',  :class_name => 'MaintenanceUpdatesFileHandler',:builder_name => "MaintenanceUpdatesTemplateBuilder",  :description => 'Worksheet records latest maintenance updates for assets'},
  {:active => 1, :name => 'Disposition Updates',  :class_name => 'DispositionUpdatesFileHandler',       :builder_name => "TransitDispositionUpdatesTemplateBuilder", :description => 'Worksheet contains final disposition updates for existing inventory.'},
  {:active => 1, :name => 'New Inventory',    :class_name => 'TransitNewInventoryFileHandler',   :builder_name => "TransitNewInventoryTemplateBuilder",  :description => 'Worksheet records updated condition, status, and mileage for existing inventory.'}
]

maintenance_types = [
  {:active => 1, :name => "Oil Change/Filter/Lube", :description => "Oil Change/Filter/Lube"},
  {:active => 1, :name => "Standard PM Inspection", :description => "Standard PM Inspection"}
]

ntd_organization_types = [
    {name: 'Area Agency on Aging', active: true},
    {name: 'City, County or Local Government Unit or Department of Transportation', active: true},
    {name: 'Independent Public Agency or Authority of Transit Service', active: true},
    {name: 'MPO, COG or Other Planning Agency', active: true},
    {name: 'Other Publicly-Owned or Privately Chartered Corporation', active: true},
    {name: 'Private-For-Profit Corportation', active: true},
    {name: 'Private-Non-Profit Corportation', active: true},
    {name: 'State Government Unit or Department of Transportation', active: true},
    {name: 'Tribe', active: true},
    {name: 'University', active: true},
    {name: 'Other', active: true},
]

service_provider_types = [
  {:active => 1, :name => 'Urban',            :code => 'URB',   :description => 'Operates in an urban area.'},
  {:active => 1, :name => 'Rural',            :code => 'RUR',   :description => 'Operates in a rural area.'},
  {:active => 1, :name => 'Shared Ride',      :code => 'SHR',   :description => 'Provides shared ride services.'},
  {:active => 1, :name => 'Intercity Bus',    :code => 'ICB',   :description => 'Provides intercity bus services.'},
  {:active => 1, :name => 'Intercity Rail',   :code => 'ICR',   :description => 'Provides intercity rail services.'}
]

vehicle_storage_method_types = [
  {:active => 1,  :name => 'Indoors', :code => 'I', :description => 'Vehicle is always stored indoors.'},
  {:active => 1,  :name => 'Outdoors', :code => 'O', :description => 'Vehicle is always stored outdoors.'},
  {:active => 1,  :name => 'Indoor/Outdoor', :code => 'B', :description => 'Vehicle is stored both indoors and outdoors.'},
  {:active => 1,  :name => 'Unknown',:code => 'X', :description => 'Vehicle storage method not supplied.'}
]

maintenance_provider_types = [
  {:active => 1,  :name => 'Self Maintained', :code => 'SM', :description => 'Self Maintained.'},
  {:active => 1,  :name => 'County',          :code => 'CO', :description => 'County.'},
  {:active => 1,  :name => 'Public Agency',   :code => 'PA', :description => 'Public Agency.'},
  {:active => 1,  :name => 'Private Entity',  :code => 'PE', :description => 'Private Entity.'},
  {:active => 1,  :name => 'Unknown',         :code => 'XX', :description => 'Maintenance provider not supplied.'}
]


organization_types = [
  {:active => 1,  :name => 'Grantor',           :class_name => "Grantor",               :display_icon_name => "fa fa-usd",    :map_icon_name => "redIcon",    :description => 'Organizations who manage funding grants.', :roles => 'guest,manager'},
  {:active => 1,  :name => 'Transit Operator',   :class_name => "TransitOperator",       :display_icon_name => "fa fa-bus",    :map_icon_name => "greenIcon",  :description => 'Transit Operator.', :roles => 'guest,user,transit_manager'},
  {:active => 1,  :name => 'Planning Partner',  :class_name => "PlanningPartner",  :display_icon_name => "fa fa-group",  :map_icon_name => "purpleIcon", :description => 'Organizations who need visibility into grantee assets for planning purposes.', :roles => 'guest'}
]

governing_body_types = [
  {:active => 1, :name => 'Corporate Board of Directors',   :description => 'Corporate Board of Directors'},
  {:active => 1, :name => 'Authority Board',   :description => 'Board of Directors'},
  {:active => 1, :name => 'County',   :description => 'County'},
  {:active => 1, :name => 'City',   :description => 'City'},
  {:active => 1, :name => 'Other',                :description => 'Other Governing Body'}
]



fta_asset_categories = [
    {name: 'Revenue Vehicles', display_icon_name: 'fa fa-bus', active: true},
    {name: 'Equipment', display_icon_name: 'fa fa-cog', active: true},
    {name: 'Facilities', display_icon_name: 'fa fa-building', active: true},
    {name: 'Infrastructure', display_icon_name: 'fa fa-road', active: true}
]
fta_asset_classes = [
    {fta_category: 'Revenue Vehicles', code: "bus", name: 'Buses (Rubber Tire Vehicles)', class_name: 'RevenueVehicle', display_icon_name: 'fa fa-bus', active: true},
    {fta_category: 'Revenue Vehicles', code: "rail_car", name: 'Rail Cars', class_name: 'RevenueVehicle', display_icon_name: 'fa fa-subway', active: true},
    {fta_category: 'Revenue Vehicles', code: "ferry", name: 'Ferries', class_name: 'RevenueVehicle', display_icon_name: 'fa fa-ship', active: true},
    {fta_category: 'Revenue Vehicles', code: "other_passenger_vehicle", name: 'Other Passenger Vehicles', class_name: 'RevenueVehicle', display_icon_name: 'fa fa-train', active: true},
    {fta_category: 'Equipment', code: "service_vehicle", name: 'Service Vehicles (Non-Revenue)', class_name: 'ServiceVehicle', display_icon_name: 'fa fa-car', active: true},
    {fta_category: 'Equipment', code: "capital_equipment", name: 'Capital Equipment', class_name: 'CapitalEquipment', display_icon_name: 'fa fa-map-signs', active: true},
    {fta_category: 'Facilities', code: "admin_facility", name: 'Administration', class_name: 'Facility', display_icon_name: 'fa fa-university', active: true},
    {fta_category: 'Facilities', code: "maintenance_facility", name: 'Maintenance', class_name: 'Facility', display_icon_name: 'fa fa-wrench', active: true},
    {fta_category: 'Facilities', code: "passenger_facility", name: 'Passenger', class_name: 'Facility', display_icon_name: 'fa fa-user', active: true},
    {fta_category: 'Facilities', code: "parking_facility", name: 'Parking', class_name: 'Facility', display_icon_name: 'fa fa-road', active: true},
    {fta_category: 'Infrastructure', code: "guideway", name: 'Guideway', class_name: 'Guideway', display_icon_name: 'fa fa-map', active: true},
    {fta_category: 'Infrastructure', code: "power_signal", name: 'Power & Signal', class_name: 'PowerSignal', display_icon_name: 'fa fa-plug', active: true},
    {fta_category: 'Infrastructure', code: "track", name: 'Track', class_name: 'Track', display_icon_name: 'fa fa-train', active: true}
]

contract_types = [
    {name: 'Contract / PO directly with Vendor', active: true},
    {name: 'Statewide (DOT) Contract / PO', active: true},
    {name: 'Contract / PO from DOT', active: true},
    {name: 'Contract / PO to DOT', active: true}
]

component_types= [
    {name: 'Substructure', fta_asset_category: 'Facilities', active:true},
    {name: 'Shell', fta_asset_category: 'Facilities', active:true},
    {name: 'Interior', fta_asset_category: 'Facilities', active:true},
    {name: 'Conveyance', fta_asset_category: 'Facilities', active:true},
    {name: 'Plumbing', fta_asset_category: 'Facilities', active:true},
    {name: 'HVAC', fta_asset_category: 'Facilities', active:true},
    {name: 'Fire Protection', fta_asset_category: 'Facilities', active:true},
    {name: 'Electrical', fta_asset_category: 'Facilities', active:true},
    {name: 'Equipment / Fare Collection', fta_asset_category: 'Facilities', active:true},
    {name: 'Site', fta_asset_category: 'Facilities', active:true},

    {name: 'Rail', fta_asset_category: 'Infrastructure', fta_asset_class: 'Track', active: true},
    {name: 'Ties', fta_asset_category: 'Infrastructure', active: true},
    {name: 'Fasteners', fta_asset_category: 'Infrastructure', fta_asset_class: 'Track', active: true},
    {name: 'Field Welds', fta_asset_category: 'Infrastructure', fta_asset_class: 'Track', active: true},
    {name: 'Joints', fta_asset_category: 'Infrastructure', fta_asset_class: 'Track', active: true},
    {name: 'Ballast', fta_asset_category: 'Infrastructure', fta_asset_class: 'Track', active: true},

    {name: 'Surface / Deck', fta_asset_category: 'Infrastructure', fta_asset_class: 'Guideway', active: true},
    {name: 'Superstructure', fta_asset_category: 'Infrastructure', fta_asset_class: 'Guideway', active: true},
    {name: 'Substructure', fta_asset_category: 'Infrastructure', fta_asset_class: 'Guideway', active: true},
    {name: 'Track Bed', fta_asset_category: 'Infrastructure', fta_asset_class: 'Guideway', active: true},
    {name: 'Culverts', fta_asset_category: 'Infrastructure', fta_asset_class: 'Guideway', active: true},
    {name: 'Perimeter', fta_asset_category: 'Infrastructure', fta_asset_class: 'Guideway', active: true},

    {name: 'Fixed Signals', fta_asset_category: 'Infrastructure', fta_asset_class: 'Power & Signal', active: true},
    {name: 'Signal House', fta_asset_category: 'Infrastructure', fta_asset_class: 'Power & Signal', active: true},
    {name: 'Contact System', fta_asset_category: 'Infrastructure', fta_asset_class: 'Power & Signal', active: true},
    {name: 'Power Equipment', fta_asset_category: 'Infrastructure', fta_asset_class: 'Power & Signal', active: true},
    {name: 'Structure', fta_asset_category: 'Infrastructure', fta_asset_class: 'Power & Signal', active: true},
]

component_subtypes = [
    {name: 'Spikes & Screws', component_type: 'Fasteners', active: true},
    {name: 'Supports', component_type: 'Fasteners', active: true},

    {name: 'Sub-Ballast', component_type: 'Track Bed', active: true},
    {name: 'Blanket', component_type: 'Track Bed', active: true},
    {name: 'Subgrade', component_type: 'Track Bed', active: true},

    {name: 'Signals', component_type: 'Fixed Signals', active: true},
    {name: 'Mounting', component_type: 'Fixed Signals', active: true},

    {name: 'Facilities - Walls', active:true},
    {name: 'Foundations - Columns', active:true},
    {name: 'Foundations - Pilings', active:true},
    {name: 'Basement - Materials', active:true},
    {name: 'Basement - Insulation', active:true},
    {name: 'Basement - Slab', active:true},
    {name: 'Basement - Floor Underpinnings', active:true},
    {name: 'Superstructure / Structural Frame - Columns', active:true},
    {name: 'Superstructure / Structural Frame - Pillars', active:true},
    {name: 'Superstructure / Structural Frame - Walls', active:true},
    {name: 'Roof - Surface', active:true},
    {name: 'Roof - Gutters', active:true},
    {name: 'Roof - Eaves', active:true},
    {name: 'Roof - Skylights', active:true},
    {name: 'Roof - Chimney Surrounds', active:true},
    {name: 'Exterior - Windows', active:true},
    {name: 'Exterior - Doors', active:true},
    {name: 'Exterior - Paint', active:true},
    {name: 'Exterior - Masonry', active:true},
    {name: 'Shell Appurtenances - Balconies', active:true},
    {name: 'Shell Appurtenances - Fire Escapes', active:true},
    {name: 'Shell Appurtenances - Gutters', active:true},
    {name: 'Shell Appurtenances - Downspouts', active:true},
    {name: 'Passenger Areas - Platform', active:true},
    {name: 'Passenger Areas - Access Tunnels / Passageways', active:true},
    {name: 'Partitions - Walls', active:true},
    {name: 'Partitions - Interior Doors', active:true},
    {name: 'Partitions - Fittings', active:true},
    {name: 'Partitions - Signage', active:true},
    {name: 'Stairs - Interior Stairs', active:true},
    {name: 'Stairs - Landings', active:true},
    {name: 'Finishes - Materials (walls)', active:true},
    {name: 'Finishes - Materials (floors)', active:true},
    {name: 'Finishes - Materials (ceilings)', active:true},
    {name: 'Finishes - Materials (all surfaces)', active:true},
    {name: 'Elevators', active:true},
    {name: 'Escalators', active:true},
    {name: 'Lifts (any type)', active:true},
    {name: 'Fixtures', active:true},
    {name: 'Water Distribution', active:true},
    {name: 'Sanitary Waste', active:true},
    {name: 'Rain Water Drainage', active:true},
    {name: 'Energy Supply', active:true},
    {name: 'Heat Generation and Distribution Systems', active:true},
    {name: 'Cooling Generation and Distribution Systems', active:true},
    {name: 'Testing, Balancing, Controls and Instrumentation', active:true},
    {name: 'Chimneys and Vents', active:true},
    {name: 'Sprinklers', active:true},
    {name: 'Standpipes', active:true},
    {name: 'Hydrants and Other Fire Protection Specialties', active:true},
    {name: 'Electrical Service & Distribution', active:true},
    {name: 'Lighting & Branch Wiring (Interior & Exterior)', active:true},
    {name: 'Communications & Security', active:true},
    {name: 'Lighting Protection', active:true},
    {name: 'Generators', active:true},
    {name: 'Emergency Lighting', active:true},
    {name: 'Maintenance & Service Equipment', active:true},
    {name: 'Turnstiles', active:true},
    {name: 'Ticket Machines', active:true},
    {name: 'Roadways / Driveways', active:true},
    {name: 'Roadways / Driveways - Signage', active:true},
    {name: 'Roadways / Driveways - Markings', active:true},
    {name: 'Roadways / Driveways - Equipment', active:true},
    {name: 'Parking Lots', active:true},
    {name: 'Parking Lots - Signage', active:true},
    {name: 'Parking Lots - Markings', active:true},
    {name: 'Parking Lots - Equipment', active:true},
    {name: 'Pedestrian Areas', active:true},
    {name: 'Pedestrian Areas - Signage', active:true},
    {name: 'Pedestrian Areas - Markings', active:true},
    {name: 'Pedestrian Areas - Equipment', active:true},
    {name: 'Site Development - Fences', active:true},
    {name: 'Site Development - Walls', active:true},
    {name: 'Site Development - Miscellaneous Structures', active:true},
    {name: 'Landscaping & Irrigation', active:true},
    {name: 'Site Utilities', active:true},

]

component_elements = [
    {name: 'Girder Guard Rail', parent: {component_type: 'Rail'},active: true},
    {name: 'Block Rail', parent: {component_type: 'Rail'},active: true},
    {name: 'Barlow Rail', parent: {component_type: 'Rail'},active: true},
    {name: 'Flanged T Rail', parent: {component_type: 'Rail'},active: true},
    {name: 'Vignoles Rail', parent: {component_type: 'Rail'},active: true},
    {name: 'Double-Headed Rail', parent: {component_type: 'Rail'},active: true},
    {name: 'Bullhead Rail', parent: {component_type: 'Rail'},active: true},

    {name: 'Conventional', parent: {component_type: 'Ties'}, active: true},
    {name: 'Slab', parent: {component_type: 'Ties'}, active: true},
    {name: 'Floating Slab', parent: {component_type: 'Ties'}, active: true},
    {name: 'Y-Shaped', parent: {component_type: 'Ties'}, active: true},
    {name: 'Twin', parent: {component_type: 'Ties'}, active: true},
    {name: 'Wide', parent: {component_type: 'Ties'}, active: true},
    {name: 'Bi-Block', parent: {component_type: 'Ties'}, active: true},
    {name: 'Frame', parent: {component_type: 'Ties'}, active: true},
    {name: 'Ladder', parent: {component_type: 'Ties'}, active: true},

    {name: 'Cut Spike', parent: {component_subtype: 'Spikes & Screws'}, active: true},
    {name: 'Dog Spike', parent: {component_subtype: 'Spikes & Screws'},active: true},
    {name: 'Chair Screw', parent: {component_subtype: 'Spikes & Screws'},active: true},
    {name: 'Fang Bolt', parent: {component_subtype: 'Spikes & Screws'},active: true},
    {name: 'Spring Spike', parent: {component_subtype: 'Spikes & Screws'},active: true},

    {name: 'Rail Chair', parent: {component_subtype: 'Supports'},active: true},
    {name: 'Tie Plate', parent: {component_subtype: 'Supports'},active: true},
    {name: 'Clip', parent: {component_subtype: 'Supports'},active: true},
    {name: 'Tension Clamp', parent: {component_subtype: 'Supports'},active: true},
    {name: 'Bolt Clamp', parent: {component_subtype: 'Supports'},active: true},
    {name: 'Rail Anchor', parent: {component_subtype: 'Supports'},active: true},

    {name: 'Flash Butt', parent: {component_type: 'Field Welds'},active: true},
    {name: 'Gas Pressure', parent: {component_type: 'Field Welds'},active: true},
    {name: 'Thermite', parent: {component_type: 'Field Welds'},active: true},
    {name: 'Enclosed Arc', parent: {component_type: 'Field Welds'},active: true},

    {name: 'Bolted', parent: {component_type: 'Joints'},active: true},
    {name: 'Compromise', parent: {component_type: 'Joints'},active: true},
    {name: 'Bonded (insulated)', parent: {component_type: 'Joints'},active: true},
    {name: 'Bonded (non-insulated)', parent: {component_type: 'Joints'},active: true},
    {name: 'Polyurethane (insulated)', parent: {component_type: 'Joints'},active: true},

    {name: 'Crushed Stone', parent: {component_type: 'Ballast'},active: true},
    {name: 'Concrete (ballastless)', parent: {component_type: 'Ballast'},active: true},


    {name: 'Ballast', parent: {component_type: 'Surface / Deck'},active: true},
    {name: 'Direct Fixation', parent: {component_type: 'Surface / Deck'},active: true},
    {name: 'Embedded', parent: {component_type: 'Surface / Deck'},active: true},
    {name: 'Open', parent: {component_type: 'Surface / Deck'},active: true},

    {name: 'Floor Beams', parent: {component_type: 'Superstructure'},active: true},
    {name: 'Girders', parent: {component_type: 'Superstructure'},active: true},
    {name: 'Stringers', parent: {component_type: 'Superstructure'},active: true},

    {name: 'Abutment', parent: {component_type: 'Substructure'},active: true},
    {name: 'Bent', parent: {component_type: 'Substructure'},active: true},
    {name: 'Pier', parent: {component_type: 'Substructure'},active: true},

    {name: 'Crushed Stone', parent: {component_subtype: 'Sub-Ballast'},active: true},
    {name: 'Gravel', parent: {component_subtype: 'Sub-Ballast'},active: true},
    {name: 'Sand', parent: {component_subtype: 'Sub-Ballast'},active: true},
    {name: 'Slag', parent: {component_subtype: 'Sub-Ballast'},active: true},

    {name: 'Asphalt', parent: {component_subtype: 'Blanket'},active: true},
    {name: 'Cinders', parent: {component_subtype: 'Blanket'},active: true},
    {name: 'Crushed Rock', parent: {component_subtype: 'Blanket'},active: true},
    {name: 'Manufactured Material', parent: {component_subtype: 'Blanket'},active: true},
    {name: 'Slag', parent: {component_subtype: 'Blanket'},active: true},

    {name: 'Basalt', parent: {component_subtype: 'Subgrade'},active: true},
    {name: 'Cemented Sedimentary Rocks', parent: {component_subtype: 'Subgrade'},active: true},
    {name: 'Clay', parent: {component_subtype: 'Subgrade'},active: true},
    {name: 'Granite', parent: {component_subtype: 'Subgrade'},active: true},
    {name: 'Gravel', parent: {component_subtype: 'Subgrade'},active: true},
    {name: 'Igneous Rocks', parent: {component_subtype: 'Subgrade'},active: true},
    {name: 'Limestone', parent: {component_subtype: 'Subgrade'},active: true},
    {name: 'Metamorphic Rocks', parent: {component_subtype: 'Subgrade'},active: true},
    {name: 'Sand', parent: {component_subtype: 'Subgrade'},active: true},
    {name: 'Sandstone', parent: {component_subtype: 'Subgrade'},active: true},
    {name: 'Silt', parent: {component_subtype: 'Subgrade'},active: true},
    {name: 'Slate', parent: {component_subtype: 'Subgrade'},active: true},
    {name: 'Soil', parent: {component_subtype: 'Subgrade'},active: true},

    {name: 'Aluminum', parent: {component_type: 'Culverts'},active: true},
    {name: 'Concrete', parent: {component_type: 'Culverts'},active: true},
    {name: 'Corrugated Steel', parent: {component_type: 'Culverts'},active: true},
    {name: 'High-Density Polyethylene', parent: {component_type: 'Culverts'},active: true},
    {name: 'Masonry', parent: {component_type: 'Culverts'},active: true},
    {name: 'Reinforced Concrete', parent: {component_type: 'Culverts'},active: true},
    {name: 'Steel', parent: {component_type: 'Culverts'},active: true},

    {name: 'Berm', parent: {component_type: 'Perimeter'},active: true},
    {name: 'Noise Barriers', parent: {component_type: 'Perimeter'},active: true},
    {name: 'Security Fencing', parent: {component_type: 'Perimeter'},active: true},

    {name: 'Semaphore', parent: {component_subtype: 'Signals'},active: true},
    {name: 'Color Lights (Searchlight)', parent: {component_subtype: 'Signals'},active: true},
    {name: 'Color Lights (Triangular)', parent: {component_subtype: 'Signals'},active: true},
    {name: 'Color Lights (Vertical)', parent: {component_subtype: 'Signals'},active: true},
    {name: 'Color Lights (Position)', parent: {component_subtype: 'Signals'},active: true},

    {name: 'Cantilver Mast', parent: {component_subtype: 'Mounting'}, active: true},
    {name: 'Electrification Support', parent: {component_subtype: 'Mounting'}, active: true},
    {name: 'Gantry', parent: {component_subtype: 'Mounting'}, active: true},
    {name: 'Ground Mount', parent: {component_subtype: 'Mounting'}, active: true},
    {name: 'Mast (Post)', parent: {component_subtype: 'Mounting'}, active: true},
    {name: 'Signal Bridge', parent: {component_subtype: 'Mounting'}, active: true},
    {name: 'Wall / Abutment', parent: {component_subtype: 'Mounting'}, active: true},

    {name: 'Overhead Contact System', parent: {component_type: 'Contact System'}, active: true},
    {name: 'Third Rail', parent: {component_type: 'Contact System'}, active: true},
    {name: 'Other Contact System', parent: {component_type: 'Contact System'}, active: true},

    {name: 'Bridge', parent: {component_type: 'Structure'}, active: true},
    {name: 'Cantilever Arm', parent: {component_type: 'Structure'}, active: true},
    {name: 'Cantilever Brackets', parent: {component_type: 'Structure'}, active: true},
    {name: 'Foundation', parent: {component_type: 'Structure'}, active: true},
    {name: 'Insulator', parent: {component_type: 'Structure'}, active: true},
    {name: 'Mast', parent: {component_type: 'Structure'}, active: true},
    {name: 'Registration Arm', parent: {component_type: 'Structure'}, active: true},
    {name: 'Registration Tube', parent: {component_type: 'Structure'}, active: true},
    {name: 'Steady Arm', parent: {component_type: 'Structure'}, active: true},
]

esl_categories = [
    {name: 'Heavy-Duty Large Bus', class_name: 'RevenueVehicle', active: true},
    {name: 'Heavy-Duty Small Bus', class_name: 'RevenueVehicle', active: true},
    {name: 'Medium-Duty and Purpose-Built Bus', class_name: 'RevenueVehicle', active: true},
    {name: 'Light Duty Mid-Sized Bus', class_name: 'RevenueVehicle', active: true},
    {name: 'Light Duty Small Bus, Cutaways, and Modified Van', class_name: 'RevenueVehicle', active: true},
    {name: 'Electric Trolley-Bus', class_name: 'RevenueVehicle', active: true},
    {name: 'Steel-Wheel Trolley', class_name: 'RevenueVehicle', active: true},
    {name: 'Ferry', class_name: 'RevenueVehicle', active: true},
    {name: 'Rail Vehicle', class_name: 'RevenueVehicle', active: true},
    {name: 'Facilities', class_name: 'Facility', active: true},
]
chasses = [
    {name: 'Chevrolet Express 3500', active: true},
    {name: 'Chevrolet Express 4500', active: true},
    {name: 'Chevrolet G3500', active: true},
    {name: 'Chevrolet G4500', active: true},
    {name: 'Ford F-350', active: true},
    {name: 'Ford F-450', active: true},
    {name: 'Ford F-550', active: true},
    {name: 'Ford F-650', active: true},
    {name: 'Ford F-750', active: true},
    {name: 'Ford Transit', active: true},
    {name: 'Freightliner M2', active: true},
    {name: 'Freightliner MB55', active: true},
    {name: 'Freightliner MB65', active: true},
    {name: 'Freightliner MB75', active: true},
    {name: 'International UC', active: true},
    {name: 'International 3200', active: true},
    {name: 'International 3300', active: true},
    {name: 'Monocoque', active: true},
    {name: 'Other', active: true}
]
ramp_manufacturers = [
    {name: 'Braun', active: true},
    {name: 'Ricon', active: true},
    {name: 'Other', active: true}
]

infrastructure_segment_unit_types = [
    {name: 'Marker Posts', active: true},
    {name: 'Lat / Long', active: true},
    {name: 'Chaining', active: true}
]

infrastructure_chain_types = [
    {name: 'Engineer (100 feet) (30.48 m)', active: true},
    {name: 'Surveyor (66 feet) (20.1168 m)', active: true}
]


infrastructure_segment_types = [
    {name: 'Main Line', fta_asset_class: 'Track', active: true},
    {name: 'Sidetrack', fta_asset_class: 'Track', active: true},
    {name: 'Siding', fta_asset_class: 'Track', active: true},
    {name: 'Passing Siding', fta_asset_class: 'Track', active: true},
    {name: 'Yard', fta_asset_class: 'Track', active: true},
    {name: 'Cut', fta_asset_class: 'Guideway', asset_subtype: 'At-Grade', active: true},
    {name: 'Embankment', fta_asset_class: 'Guideway', asset_subtype: 'At-Grade', active: true},
    {name: 'Level', fta_asset_class: 'Guideway', asset_subtype: 'At-Grade', active: true},

    {name: 'Arch', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
    {name: 'Through Arch', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
    {name: 'Beam', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
    {name: 'Viaduct', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
    {name: 'Bow String', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
    {name: 'Box Girder', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
    {name: 'Cable-Stayed', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
    {name: 'Cantilever', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
    {name: 'Cantilever Spar Cable-Stayed', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
    {name: 'Girder', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
    {name: 'Continuous Span Girder', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
    {name: 'Integral', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
    {name: 'Extradosed', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
    {name: 'Plate Girder', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
    {name: 'Rigid Frame', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
    {name: 'Segmental', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
    {name: 'Self-Anchored Suspension', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
    {name: 'Side-Spar Cable-Stayed', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
    {name: 'Suspension', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
    {name: 'Transporter', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
    {name: 'Trestle', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
    {name: 'Truss Arch', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},
    {name: 'Tubular', fta_asset_class: 'Guideway', asset_subtype: 'Bridge', active: true},

    {name: 'Bored', fta_asset_class: 'Guideway', asset_subtype: 'Tunnel', active: true},
    {name: 'Cut-and-Cover', fta_asset_class: 'Guideway', asset_subtype: 'Tunnel', active: true},
    {name: 'Immersed', fta_asset_class: 'Guideway', asset_subtype: 'Tunnel', active: true},

    {name: 'Running Line', fta_asset_class: 'Power & Signal', active: true},
    {name: 'Interlocking', fta_asset_class: 'Power & Signal', active: true},
    {name: 'Highway Crossing', fta_asset_class: 'Power & Signal', active: true},
    {name: 'Movable Bridge', fta_asset_class: 'Power & Signal', active: true},
    {name: 'Special Track', fta_asset_class: 'Power & Signal', active: true}
]

infrastructure_operation_method_types = [
    {name: 'Block (Manual)', active: true},
    {name: 'Block (Absolute Permissive)', active: true},
    {name: 'Block (Automatic)', active: true},
    {name: 'Block (Fixed)', active: true},
    {name: 'Block (Moving)', active: true},
]
infrastructure_control_system_types = [
    {name: 'Track Warrant Control', active: true},
    {name: 'Centralized Traffic Control', active: true},
    {name: 'Positive Train Control', active: true},
]

infrastructure_gauge_types = [
    {name: 'Standard', active: true},
    {name: 'Broad', active: true},
    {name: 'Narrow', active: true}
]

infrastructure_reference_rails = [
    {name: 'East (North / South Track)', active: true},
    {name: 'North (East / West Track)', active: true},
    {name: 'Outer', active: true},
    {name: 'Center Line', active: true}
]

infrastructure_bridge_types = [
    {name: 'Fixed', active: true},
    {name: 'Movable (Swing)', active: true},
    {name: 'Movable (Bascule)', active: true},
    {name: 'Movable (Vertical Lift)', active: true},
]

infrastructure_crossings = [
    {name: 'Land', active: true},
    {name: 'Roadway', active: true},
    {name: 'Track', active: true},
    {name: 'Valley', active: true},
    {name: 'Water', active: true},
]

infrastructure_rail_joinings = [
    {name: 'Jointed Track', active: true},
    {name: 'Continuous Welded Rail', active: true}
]

infrastructure_voltage_types = [
    {name: '600 V DC', active: true},
    {name: '750 V DC', active: true},
    {name: '>1,200 V DC', active: true},
    {name: '1,500 V DC', active: true},
    {name: '3 kV DC', active: true},
    {name: '12.5 kV AC, 25 Hz', active: true},
    {name: '15 kV AC, 16.7 Hz', active: true},
    {name: '25 kV AC, 50 Hz', active: true},
    {name: '25 kV AC, 60 Hz', active: true},
    {name: '50 kV AC, 60 Hz', active: true}
]

infrastructure_cap_materials = [
    {name: 'Concrete', active: true},
    {name: 'Masonry', active: true},
    {name: 'Steel', active: true},
    {name: 'Timber', active: true}
]

infrastructure_foundations = [
    {name: 'Spread Footing', active: true},
    {name: 'Piles', active: true},
    {name: 'Drilled Shafts', active: true},
    {name: 'Caissons', active: true},
]

component_materials = [
    {name: 'Wooden', component_type: 'Ties', active: true},
    {name: 'Concrete', component_type: 'Ties', active: true},
    {name: 'Steel', component_type: 'Ties', active: true},
    {name: 'Plastic', component_type: 'Ties', active: true},

    {name: 'Asphalt', component_type: 'Surface / Deck', active: true},
    {name: 'Concrete', component_type: 'Surface / Deck', active: true},
    {name: 'Masonry', component_type: 'Surface / Deck', active: true},
    {name: 'Steel', component_type: 'Surface / Deck', active: true},
    {name: 'Timber', component_type: 'Surface / Deck', active: true},

    {name: 'Concrete', component_type: 'Superstructure', active: true},
    {name: 'Iron', component_type: 'Superstructure', active: true},
    {name: 'Masonry', component_type: 'Superstructure', active: true},
    {name: 'Steel', component_type: 'Superstructure', active: true},
    {name: 'Timber', component_type: 'Superstructure', active: true},

    {name: 'Concrete', component_type: 'Substructure', active: true},
    {name: 'Masonry', component_type: 'Substructure', active: true},
    {name: 'Steel', component_type: 'Substructure', active: true},
    {name: 'Timber', component_type: 'Substructure', active: true},
]

fta_guideway_types = [
    {name: 'At-Grade/Ballast (including Expressway)', active: true, :fta_asset_class => 'Guideway', sort_order: 1},
    {name: 'At-Grade/In-Street/Embedded', active: true, :fta_asset_class => 'Guideway', sort_order: 2},
    {name: 'Elevated/Retained Fill', active: true, :fta_asset_class => 'Guideway', sort_order: 3},
    {name: 'Elevated/Concrete', active: true, :fta_asset_class => 'Guideway', sort_order: 4},
    {name: 'Elevated/Steel Viaduct or Bridge', active: true, :fta_asset_class => 'Guideway', sort_order: 5},
    {name: 'Below-Grade/Retained Cut', active: true, :fta_asset_class => 'Guideway', sort_order: 6},
    {name: 'Below-Grade/Cut-and-Cover Tunnel', active: true, :fta_asset_class => 'Guideway', sort_order: 7},
    {name: 'Below-Grade/Bored or Blasted Tunnel', active: true, :fta_asset_class => 'Guideway', sort_order: 8},
    {name: 'Below-Grade/Submerged Tube', active: true, :fta_asset_class => 'Guideway', sort_order: 9}
]

fta_track_types = [
    {name: 'Tangent - Revenue Service', active: true, :fta_asset_class => 'Track', sort_order: 15},
    {name: 'Curve - Revenue Service', active: true, :fta_asset_class => 'Track', sort_order: 16},
    {name: 'Non-Revenue Service', active: true, :fta_asset_class => 'Track', sort_order: 17},
    {name: 'Revenue Track - No Capital Replacement Responsibility', active: true, :fta_asset_class => 'Track', sort_order: 18},
    {name: 'Double crossover', active: true, :fta_asset_class => 'Track', sort_order: 19},
    {name: 'Single crossover', active: true, :fta_asset_class => 'Track', sort_order: 20},
    {name: 'Single turnout', active: true, :fta_asset_class => 'Track', sort_order: 21},
    {name: 'Lapped turnout', active: true, :fta_asset_class => 'Track', sort_order: 22},
    {name: 'Grade crossing', active: true, :fta_asset_class => 'Track', sort_order: 23},
    {name: 'Rail crossings', active: true, :fta_asset_class => 'Track', sort_order: 24},
    {name: 'Slip switch', active: true, :fta_asset_class => 'Track', sort_order: 25},
]

fta_power_signal_types = [
    {name: 'Train Control and Signaling', active: true, :fta_asset_class => 'Power & Signal', sort_order: 14},
    {name: 'Substation Building', active: true, :fta_asset_class => 'Power & Signal', sort_order: 10},
    {name: 'Substation Equipment', active: true, :fta_asset_class => 'Power & Signal', sort_order: 11},
    {name: 'Third Rail/Power Distribution', active: true, :fta_asset_class => 'Power & Signal', sort_order: 12},
    {name: 'Overhead Contact System/Power Distribution', active: true, :fta_asset_class => 'Power & Signal', sort_order: 13}
]


performance_restriction_types = [
    {name: 'Maintenance', description: 'Maintenance', active: true},
    {name: 'Rail Defect', description: 'Rail Defect', active: true},
    {name: 'Signal, Controls Issue', description: 'Signal, Controls Issue', active: true},
    {name: 'Bridge Conditions', description: 'Bridge Conditions', active: true},
    {name: 'Track Geometry', description: 'Track Geometry', active: true},
    {name: 'Construction', description: 'Construction', active: true},
    {name: 'Weather', description: 'Weather', active: true},
    {name: 'Other', description: 'Other', active: true},
]

out_of_service_status_types = [
    { name: "In Storage", description: "In Storage", active: true },
    { name: "Short Term - Minor Repairs", description: "Short Term - Minor Repairs", active: true },
    { name: "Short Term - Routine Maintenance", description: "Short Term - Routine Maintenance", active: true },
    { name: "Long Term - Major Repairs", description: "Long Term - Major Repairs", active: true },
    { name: "Awaiting Sale or disposal", description: "Awaiting Sale or disposal", active: true }
]

replace_tables = %w{ asset_types fuel_types vehicle_features rail_safety_features vehicle_usage_codes vehicle_rebuild_types fta_mode_types fta_private_mode_types fta_bus_mode_types fta_agency_types fta_service_area_types
  fta_service_types fta_funding_types fta_ownership_types facility_capacity_types
  facility_features leed_certification_types district_types maintenance_provider_types file_content_types ntd_organization_types service_provider_types organization_types maintenance_types
  vehicle_storage_method_types governing_body_types asset_fleet_types fta_asset_categories contract_types esl_categories ramp_manufacturers infrastructure_segment_unit_types infrastructure_chain_types infrastructure_segment_unit_types infrastructure_operation_method_types infrastructure_control_system_types infrastructure_gauge_types infrastructure_reference_rails infrastructure_bridge_types infrastructure_crossings infrastructure_rail_joinings infrastructure_cap_materials infrastructure_foundations performance_restriction_types out_of_service_status_types
  }

# Ignore foreign key constraints in order to truncate fta_asset_categories table
ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS = 0;")

replace_tables.each do |table_name|
  puts "  Loading #{table_name}"
  if is_mysql
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table_name};")
  elsif is_sqlite
    ActiveRecord::Base.connection.execute("DELETE FROM #{table_name};")
  else
    ActiveRecord::Base.connection.execute("TRUNCATE #{table_name} RESTART IDENTITY;")
  end
  data = eval(table_name)
  klass = table_name.classify.constantize
  data.each do |row|
    x = klass.new(row)
    x.save!
  end
end

# add in county districts
require TransamTransit::Engine.root.join('db', 'seeds', 'districts_counties_seeds.rb')

# Reset foreign key checks
ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS = 1;")

table_name = 'chasses'
puts "  Loading #{table_name}"
if is_mysql
  ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table_name};")
elsif is_sqlite
  ActiveRecord::Base.connection.execute("DELETE FROM #{table_name};")
else
  ActiveRecord::Base.connection.execute("TRUNCATE #{table_name} RESTART IDENTITY;")
end
data = eval(table_name)
data.each do |row|
  x = Chassis.new(row)
  x.save!
end

table_name = 'asset_subtypes'
puts "  Loading #{table_name}"
if is_mysql
  ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table_name};")
elsif is_sqlite
  ActiveRecord::Base.connection.execute("DELETE FROM #{table_name};")
else
  ActiveRecord::Base.connection.execute("TRUNCATE #{table_name} RESTART IDENTITY;")
end
data = eval(table_name)
data.each do |row|
  x = AssetSubtype.new(row.except(:belongs_to, :type))
  x.asset_type = AssetType.where(:name => row[:type]).first
  x.save!
end

table_name = 'fta_asset_classes'
puts "  Loading #{table_name}"
if is_mysql
  ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table_name};")
elsif is_sqlite
  ActiveRecord::Base.connection.execute("DELETE FROM #{table_name};")
else
  ActiveRecord::Base.connection.execute("TRUNCATE #{table_name} RESTART IDENTITY;")
end
data = eval(table_name)
data.each do |row|
  x = FtaAssetClass.new(row.except(:fta_category))
  x.fta_asset_category = FtaAssetCategory.find_by(name: row[:fta_category])
  x.save!
end
['fta_vehicle_types', 'fta_support_vehicle_types', 'fta_facility_types', 'fta_equipment_types', 'fta_track_types', 'fta_power_signal_types', 'fta_guideway_types'].each do |table_name|
  puts "  Loading #{table_name}"
  if is_mysql
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table_name};")
  elsif is_sqlite
    ActiveRecord::Base.connection.execute("DELETE FROM #{table_name};")
  else
    ActiveRecord::Base.connection.execute("TRUNCATE #{table_name} RESTART IDENTITY;")
  end
  data = eval(table_name)
  data.each do |row|
    x = table_name.classify.constantize.new(row.except(:fta_asset_class))
    x.fta_asset_class = FtaAssetClass.find_by(name: row[:fta_asset_class])
    x.save!
  end
end

infrastructure = FtaAssetCategory.find_by(name: 'Infrastructure')
['component_types', 'component_subtypes', 'component_elements'].each do |table_name|
    data = eval(table_name)
    data.each do |row|
        x = table_name.classify.constantize.new(row.except(:fta_asset_category, :fta_asset_class, :component_type, :parent))
        ['fta_asset_category', 'fta_asset_class', 'component_type'].each do |assoc|
            x.send("#{assoc}=", assoc.classify.constantize.find_by(name: row[assoc.to_sym])) if row[assoc.to_sym]
        end
        if row[:parent]
            if row[:parent].first[0].to_s.classify == 'ComponentType'
                x.parent = ComponentType.find_by(name: row[:parent].first[1], fta_asset_category_id: infrastructure.id)
            else
                x.parent = row[:parent].first[0].to_s.classify.constantize.find_by(name: row[:parent].first[1])
            end
        end

        x.save!
    end
end

['component_materials'].each do |table_name|
    data = eval(table_name)
    data.each do |row|
        x = table_name.classify.constantize.new(row.except(:component_type))
        x.component_type = ComponentType.find_by(name: row[:component_type], fta_asset_category_id: infrastructure.id)
        x.save!
    end
end

table_name = 'infrastructure_segment_types'
puts "  Loading #{table_name}"
if is_mysql
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table_name};")
elsif is_sqlite
    ActiveRecord::Base.connection.execute("DELETE FROM #{table_name};")
else
    ActiveRecord::Base.connection.execute("TRUNCATE #{table_name} RESTART IDENTITY;")
end
data = eval(table_name)
data.each do |row|
    x = InfrastructureSegmentType.new(row.except(:fta_asset_class, :asset_subtype))
    x.fta_asset_class = FtaAssetClass.find_by(name: row[:fta_asset_class]) if row[:fta_asset_class]
    x.asset_subtype = AssetSubtype.find_by(name: row[:asset_subtype]) if row[:asset_subtype]
    x.save!
end


require_relative File.join("seeds", 'team_ali_code_seeds') # TEAM ALI Codes are seeded from a separate file

# load the rail/locomotive seed data
require_relative File.join("seeds", 'rail.seeds') # Rail assets are seeded from a separate file

# These tables are merged with core tables

rule_sets = [
    {name: 'TAM Policy', class_name: 'TamPolicy', active: true}
]

roles = [
  {:privilege => false, :name => 'transit_manager', :weight => 5, :show_in_user_mgmt => true, :label => 'Manager'},
  {:privilege => true, :name => 'director_transit_operations', :show_in_user_mgmt => true},
  {:privilege => true, :name => 'ntd_contact', :label => 'NTD Contact', :show_in_user_mgmt => true},
  {name: 'tam_manager', role_parent_id: Role.find_by(name: 'manager').id, privilege: true, label: 'TAM Manager', show_in_user_mgmt: true, weight: 11},
  {name: 'tam_group_lead', privilege: true, label: 'TAM Group Lead', show_in_user_mgmt: false, weight: 11},
  {name: 'maintenance_contractor', role_parent_id: Role.find_by(name: 'guest').id, show_in_user_mgmt: true, privilege: true, label: 'Maintenance - Contractor', weight: 2}
]

asset_event_types = [
  {:active => 1, :name => 'Mileage',       :display_icon_name => "fa fa-road",       :description => 'Mileage Update',       :class_name => 'MileageUpdateEvent',      :job_name => 'AssetMileageUpdateJob'},
  {:active => 1, :name => 'NTD Mileage',       :display_icon_name => "fa fa-road",       :description => 'End of Year Odometer Reading for NTD A-30',       :class_name => 'NtdMileageUpdateEvent',   :job_name => ''},
  {:active => 1, :name => 'Operations metrics',      :display_icon_name => "fa fa-calculator",        :description => 'Operations Update',:class_name => 'OperationsUpdateEvent',     :job_name => 'AssetOperationsUpdateJob'},
  {:active => 1, :name => 'Facility operations metrics',      :display_icon_name => "fa fa-calculator",        :description => 'Facility Operations Update',:class_name => 'FacilityOperationsUpdateEvent',     :job_name => 'AssetFacilityOperationsUpdateJob'},
  {:active => 1, :name => 'Vehicle use metrics',           :display_icon_name => "fa fa-line-chart",      :description => 'Vehicle Usage Update',     :class_name => 'VehicleUsageUpdateEvent',          :job_name => 'AssetVehicleUsageUpdateJob'},
  {:active => 1, :name => 'Storage method',       :display_icon_name => "fa fa-star-half-o",       :description => 'Storage Method',       :class_name => 'StorageMethodUpdateEvent',      :job_name => 'AssetStorageMethodUpdateJob'},
  {:active => 1, :name => 'Usage codes',       :display_icon_name => "fa fa-star-half-o",       :description => 'Usage Codes',       :class_name => 'UsageCodesUpdateEvent',      :job_name => 'AssetUsageCodesUpdateJob'},
  {:active => 1, :name => 'Maintenance provider type',       :display_icon_name => "fa fa-cog",       :description => 'Maintenance Provider',       :class_name => 'MaintenanceProviderUpdateEvent',      :job_name => 'AssetMaintenanceProviderUpdateJob'},
  {:active => 1, :name => 'Performance restrictions', :display_icon_name => 'fa fa-tachometer', :description => 'Performance Restriction Update', :class_name => 'PerformanceRestrictionUpdateEvent', :job_name => ''}
]


condition_estimation_types = [
  {:active => 1, :name => 'TERM',           :class_name => 'TermEstimationCalculator',          :description => 'Asset condition is estimated using FTA TERM approximations.'}
]

report_types = [
  {:active => 1, :name => 'Planning Report',     :display_icon_name => "fa fa-line-chart",  :description => 'Planning Report.'},
]

service_life_calculation_types = [
  {:active => 1, :name => 'Age and Mileage',                :class_name => 'ServiceLifeAgeAndMileage',   :description => 'Calculate the replacement year based on the age or mileage conditions both being met.'},
  {:active => 1, :name => 'Age or Mileage',                 :class_name => 'ServiceLifeAgeOrMileage',    :description => 'Calculate the replacement year based on either the age of the asset or mileage conditions being met.'},
  {:active => 1, :name => 'Age and Mileage and Condition',  :class_name => 'ServiceLifeAgeAndMileageAndCondition',   :description => 'Calculate the replacement year based on all of the age and condition and mileage conditions being met.'},
  {:active => 1, :name => 'Age or Mileage or Condition',    :class_name => 'ServiceLifeAgeOrMileageOrCondition',   :description => 'Calculate the replacement year based on any of the age and condition and mileage conditions being met.'},
  {:active => 1, :name => 'Condition and Mileage',          :class_name => 'ServiceLifeConditionAndMileage',   :description => 'Calculate the replacement year based on both the asset and mileage conditions both being met.'},
  {:active => 1, :name => 'Condition or Mileage',           :class_name => 'ServiceLifeConditionOrMileage',   :description => 'Calculate the replacement year based on either of the asset and mileage conditions being met.'}
]

manufacturers = [
    {active: 1, filter: 'Vehicle', code: "AAI", name: "Allen Ashley Inc."},
    {active: 1, filter: 'Vehicle', code: "ABB", name: "Asea Brown Boveri Ltd."},
    {active: 1, filter: 'Vehicle', code: "ABI", name: "Advanced Bus Industries"},
    {active: 1, filter: 'Vehicle', code: "ACF", name: "American Car and Foundry Company"},
    {active: 1, filter: 'Vehicle', code: "ACI", name: "American Coastal Industries"},
    {active: 1, filter: 'Vehicle', code: "AEG", name: "AEG Transportation Systems"},
    {active: 1, filter: 'Vehicle', code: "AII", name: "American Ikarus Inc."},
    {active: 1, filter: 'Vehicle', code: "ALL", name: "Allen Marine, Inc."},
    {active: 1, filter: 'Vehicle', code: "ALS", name: "ALSTOM Transport"},
    {active: 1, filter: 'Vehicle', code: "ALW", name: "ALWEG"},
    {active: 1, filter: 'Vehicle', code: "ALX", name: "Alexander Dennis Limited"},
    {active: 1, filter: 'Vehicle', code: "AMD", name: "AMD Marine Consulting Pty Ltd"},
    {active: 1, filter: 'Vehicle', code: "AMG", name: "AM General Corporation"},
    {active: 1, filter: 'Vehicle', code: "AMI", name: "Amrail Inc."},
    {active: 1, filter: 'Vehicle', code: "AMT", name: "AmTran Corporation"},
    {active: 1, filter: 'Vehicle', code: "ARB", name: "Arboc Mobility LLC"},
    {active: 1, filter: 'Vehicle', code: "ASK", name: "AAI/Skoda"},
    {active: 1, filter: 'Vehicle', code: "ATC", name: "American Transportation Corporation"},
    {active: 1, filter: 'Vehicle', code: "AZD", name: "Azure Dynamics Corporation"},
    {active: 1, filter: 'Vehicle', code: "BBB", name: "Blue Bird Corporation"},
    {active: 1, filter: 'Vehicle', code: "BEC", name: "Brookville Equipment Corporation"},
    {active: 1, filter: 'Vehicle', code: "BFC", name: "Breda Transportation Inc."},
    {active: 1, filter: 'Vehicle', code: "BIA", name: "Bus Industries of America"},
    {active: 1, filter: 'Vehicle', code: "BLM", name: "Boise Locomotive Works"},
    {active: 1, filter: 'Vehicle', code: "BLN", name: "Blount Boats, Inc."},
    {active: 1, filter: 'Vehicle', code: "BOM", name: "Bombardier Corporation"},
    {active: 1, filter: 'Vehicle', code: "BOY", name: "Boyertown Auto Body Works"},
    {active: 1, filter: 'Vehicle', code: "BRA", name: "Braun"},
    {active: 1, filter: 'Vehicle', code: "BRX", name: "Breaux's Bay Craft, Inc."},
    {active: 1, filter: 'Vehicle', code: "BUD", name: "Budd Company"},
    {active: 1, filter: 'Vehicle', code: "BVC", name: "Boeing Vertol Company"},
    {active: 1, filter: 'Vehicle', code: "BYD", name: "Build Your Dreams, Inc."},
    {active: 1, filter: 'Vehicle', code: "CAF", name: "Construcciones y Auxiliar de Ferrocarriles (CAF)"},
    {active: 1, filter: 'Vehicle', code: "CBC", name: "Collins Bus Corporation (form. Collins Industries Inc./COL)"},
    {active: 1, filter: 'Vehicle', code: "CBR", name: "Carter Brothers"},
    {active: 1, filter: 'Vehicle', code: "CBW", name: "Carpenter Industries LLC (form. Carpenter Manufacturing Inc.)"},
    {active: 1, filter: 'Vehicle', code: "CCC", name: "Cable Car Concepts Inc."},
    {active: 1, filter: 'Vehicle', code: "CCI", name: "Chance Bus Inc. (formerly Chance Manufacturing Company/CHI)"},
    {active: 1, filter: 'Vehicle', code: "CEQ", name: "Coach and Equipment Manufacturing Company"},
    {active: 1, filter: 'Vehicle', code: "CHA", name: "Chance Manufacturing Company"},
    {active: 1, filter: 'Vehicle', code: "CHR", name: "New Chrysler"},
    {active: 1, filter: 'Vehicle', code: "CMC", name: "Champion Motor Coach Inc."},
    {active: 1, filter: 'Vehicle', code: "CMD", name: "Chevrolet Motor Division - GMC"},
    {active: 1, filter: 'Vehicle', code: "CSC", name: "California Street Cable Railroad Company"},
    {active: 1, filter: 'Vehicle', code: "CVL", name: "Canadian Vickers Ltd."},
    {active: 1, filter: 'Vehicle', code: "DAK", name: "Dakota Creek Industries, Inc."},
    {active: 1, filter: 'Vehicle', code: "DER", name: "Derecktor"},
    {active: 1, filter: 'Vehicle', code: "DHI", name: "Daewoo Heavy Industries"},
    {active: 1, filter: 'Vehicle', code: "DIA", name: "Diamond Coach Corporation (formerly Coons Mfg. Inc./CMI)"},
    {active: 1, filter: 'Vehicle', code: "DKK", name: "Double K, Inc. (form. Hometown Trolley)"},
    {active: 1, filter: 'Vehicle', code: "DMC", name: "Dina/Motor Coach Industries (MCI)"},
    {active: 1, filter: 'Vehicle', code: "DTD", name: "Dodge Division - Chrysler Corporation"},
    {active: 1, filter: 'Vehicle', code: "DUC", name: "Dutcher Corporation"},
    {active: 1, filter: 'Vehicle', code: "DUP", name: "Dupont Industries"},
    {active: 1, filter: 'Vehicle', code: "DWC", name: "Duewag Corporation"},
    {active: 1, filter: 'Vehicle', code: "EBC", name: "ElDorado Bus (EBC Inc.)"},
    {active: 1, filter: 'Vehicle', code: "EBU", name: "Ebus, Inc."},
    {active: 1, filter: 'Vehicle', code: "EDN", name: "ElDorado National (formerly El Dorado/EBC/Nat. Coach/ NCC)"},
    {active: 1, filter: 'Vehicle', code: "EII", name: "Eagle Bus Manufacturing"},
    {active: 1, filter: 'Vehicle', code: "ELK", name: "Elkhart Coach (Division of Forest River, Inc.)"},
    {active: 1, filter: 'Vehicle', code: "FCH", name: "Ferries and Cliff House Railway"},
    {active: 1, filter: 'Vehicle', code: "FDC", name: "Federal Coach"},
    {active: 1, filter: 'Vehicle', code: "FIL", name: "Flyer Industries Ltd (aka New Flyer Industries)"},
    {active: 1, filter: 'Vehicle', code: "FLT", name: "Flxette Corporation"},
    {active: 1, filter: 'Vehicle', code: "FLX", name: "Flexible Corporation"},
    {active: 1, filter: 'Vehicle', code: "FRC", name: "Freightliner Corporation"},
    {active: 1, filter: 'Vehicle', code: "FRD", name: "Ford Motor Corporation"},
    {active: 1, filter: 'Vehicle', code: "FRE", name: "Freeport Shipbuilding, Inc."},
    {active: 1, filter: 'Vehicle', code: "FSC", name: "Ferrostaal Corporation"},
    {active: 1, filter: 'Vehicle', code: "GCA", name: "General Coach America, Inc."},
    {active: 1, filter: 'Vehicle', code: "GCC", name: "Goshen Coach"},
    {active: 1, filter: 'Vehicle', code: "GEC", name: "General Electric Corporation"},
    {active: 1, filter: 'Vehicle', code: "GEO", name: "GEO Shipyard, Inc."},
    {active: 1, filter: 'Vehicle', code: "GIL", name: "Gillig Corporation"},
    {active: 1, filter: 'Vehicle', code: "GIR", name: "Girardin Corporation"},
    {active: 1, filter: 'Vehicle', code: "GLF", name: "Gulf Craft, LLC"},
    {active: 1, filter: 'Vehicle', code: "GLH", name: "Gladding Hearn"},
    {active: 1, filter: 'Vehicle', code: "GLV", name: "Glaval Bus"},
    {active: 1, filter: 'Vehicle', code: "GMC", name: "General Motors Corporation"},
    {active: 1, filter: 'Vehicle', code: "GML", name: "General Motors of Canada Ltd."},
    {active: 1, filter: 'Vehicle', code: "GOM", name: "Gomaco"},
    {active: 1, filter: 'Vehicle', code: "GTC", name: "Gomaco Trolley Company"},
    {active: 1, filter: 'Vehicle', code: "HIT", name: "Hitachi"},
    {active: 1, filter: 'Vehicle', code: "HMC", name: "American Honda Motor Company, Inc."},
    {active: 1, filter: 'Vehicle', code: "HSC", name: "Hawker Siddeley Canada"},
    {active: 1, filter: 'Vehicle', code: "HYU", name: "Hyundai Rotem"},
    {active: 1, filter: 'Vehicle', code: "INE", name: "Inekon Group, a.s."},
    {active: 1, filter: 'Vehicle', code: "INT", name: "International"},
    {active: 1, filter: 'Vehicle', code: "IRB", name: "Renault & Iveco"},
    {active: 1, filter: 'Vehicle', code: "JCC", name: "Jewett Car Company"},
    {active: 1, filter: 'Vehicle', code: "JHC", name: "John Hammond Company"},
    {active: 1, filter: 'Vehicle', code: "KAW", name: "Kawasaki Rail Car Inc. (formerly Kawasaki Heavy Industries)"},
    {active: 1, filter: 'Vehicle', code: "KIA", name: "Kia Motors"},
    {active: 1, filter: 'Vehicle', code: "KIN", name: "Kinki Sharyo USA"},
    {active: 1, filter: 'Vehicle', code: "KKI", name: "Krystal Koach Inc."},
    {active: 1, filter: 'Vehicle', code: "MAF", name: "Mafersa"},
    {active: 1, filter: 'Vehicle', code: "MAN", name: "American MAN Corporation"},
    {active: 1, filter: 'Vehicle', code: "MBB", name: "M.B.B."},
    {active: 1, filter: 'Vehicle', code: "MBR", name: "Mahoney Brothers"},
    {active: 1, filter: 'Vehicle', code: "MBZ", name: "Mercedes Benz"},
    {active: 1, filter: 'Vehicle', code: "MCI", name: "Motor Coach Industries International (DINA)"},
    {active: 1, filter: 'Vehicle', code: "MDI", name: "Mid Bus Inc."},
    {active: 1, filter: 'Vehicle', code: "MER", name: "Ford or individual makes"},
    {active: 1, filter: 'Vehicle', code: "MKI", name: "American Passenger Rail Car Company (formerly Morrison-Knudsen)"},
    {active: 1, filter: 'Vehicle', code: "MNA", name: "Mitsibushi Motors; Mitsubishi Motors North America, Inc."},
    {active: 1, filter: 'Vehicle', code: "MOL", name: "Molly Corporation"},
    {active: 1, filter: 'Vehicle', code: "MPT", name: "Motive Power Industries (formerly Boise Locomotive)"},
    {active: 1, filter: 'Vehicle', code: "MSR", name: "Market Street Railway"},
    {active: 1, filter: 'Vehicle', code: "MTC", name: "Metrotrans Corporation"},
    {active: 1, filter: 'Vehicle', code: "MVN", name: "Mobility Ventures"},
    {active: 1, filter: 'Vehicle', code: "NAB", name: "North American Bus Industries Inc. (form. Ikarus USA Inc./IKU)"},
    {active: 1, filter: 'Vehicle', code: "NAT", name: "North American Transit Inc."},
    {active: 1, filter: 'Vehicle', code: "NAV", name: "Navistar International Corporation (also known as International/INT)"},
    {active: 1, filter: 'Vehicle', code: "NBB", name: "Nichols Brothers Boat Builders"},
    {active: 1, filter: 'Vehicle', code: "NBC", name: "National Mobility Corporation"},
    {active: 1, filter: 'Vehicle', code: "NCC", name: "National Coach Corporation"},
    {active: 1, filter: 'Vehicle', code: "NEO", name: "Neoplan  USA Corporation"},
    {active: 1, filter: 'Vehicle', code: "NFA", name: "New Flyer of America"},
    {active: 1, filter: 'Vehicle', code: "NIS", name: "Nissan"},
    {active: 1, filter: 'Vehicle', code: "NOV", name: "NOVA Bus Corporation"},
    {active: 1, filter: 'Vehicle', code: "OBI", name: "Orion Bus Industries Ltd. (formerly Ontario Bus Industries)"},
    {active: 1, filter: 'Vehicle', code: "OCC", name: "Overland Custom Coach Inc."},
    {active: 1, filter: 'Vehicle', code: "OTC", name: "Oshkosh Truck Corporation"},
    {active: 1, filter: 'Vehicle', code: "PCF", name: "PACCAR (Pacific Car and Foundry Company)"},
    {active: 1, filter: 'Vehicle', code: "PCI", name: "Prevost Car Inc."},
    {active: 1, filter: 'Vehicle', code: "PLY", name: "Plymouth Division-Chrysler Corp."},
    {active: 1, filter: 'Vehicle', code: "PRO", name: "Proterra Inc."},
    {active: 1, filter: 'Vehicle', code: "PST", name: "Pullman-Standard"},
    {active: 1, filter: 'Vehicle', code: "PTC", name: "Perley Thomas Car Company"},
    {active: 1, filter: 'Vehicle', code: "PTE", name: "Port Everglades Yacht & Ship"},
    {active: 1, filter: 'Vehicle', code: "RHR", name: "Rohr Corporation"},
    {active: 1, filter: 'Vehicle', code: "RIC", name: "Rico Industries"},
    {active: 1, filter: 'Vehicle', code: "SBI", name: "SuperBus Inc."},
    {active: 1, filter: 'Vehicle', code: "SCC", name: "Sabre Bus and Coach Corp. (form. Sabre Carriage Comp.)"},
    {active: 1, filter: 'Vehicle', code: "SDU", name: "Siemens Mass Transit Division"},
    {active: 1, filter: 'Vehicle', code: "SFB", name: "Societe Franco-Belge De Material"},
    {active: 1, filter: 'Vehicle', code: "SFM", name: "San Francisco Muni"},
    {active: 1, filter: 'Vehicle', code: "SHI", name: "Shepard Brothers Inc."},
    {active: 1, filter: 'Vehicle', code: "SLC", name: "St. Louis Car Company"},
    {active: 1, filter: 'Vehicle', code: "SOF", name: "Soferval"},
    {active: 1, filter: 'Vehicle', code: "SOJ", name: "Sojitz Corporation of America (formerly Nissho Iwai American)"},
    {active: 1, filter: 'Vehicle', code: "SPC", name: "Startrans (Supreme Corporation)"},
    {active: 1, filter: 'Vehicle', code: "SPR", name: "Spartan Motors Inc."},
    {active: 1, filter: 'Vehicle', code: "SSI", name: "Stewart Stevenson Services Inc."},
    {active: 1, filter: 'Vehicle', code: "STE", name: "Steiner Shipyards, Inc."},
    {active: 1, filter: 'Vehicle', code: "STR", name: "Starcraft"},
    {active: 1, filter: 'Vehicle', code: "SUB", name: "Subaru of America or Fuji Heavy Industries Ltd."},
    {active: 1, filter: 'Vehicle', code: "SUL", name: "Sullivan Bus & Coach Limited"},
    {active: 1, filter: 'Vehicle', code: "SUM", name: "Sumitomo Corporation"},
    {active: 1, filter: 'Vehicle', code: "SVM", name: "Specialty Vehicle Manufacturing Corporation"},
    {active: 1, filter: 'Vehicle', code: "TBB", name: "Thomas Built Buses"},
    {active: 1, filter: 'Vehicle', code: "TCC", name: "Tokyu Car Company"},
    {active: 1, filter: 'Vehicle', code: "TEI", name: "Trolley Enterprises Inc."},
    {active: 1, filter: 'Vehicle', code: "TMC", name: "Transportation Manufacturing Company"},
    {active: 1, filter: 'Vehicle', code: "TOU", name: "Tourstar"},
    {active: 1, filter: 'Vehicle', code: "TOY", name: "Toyota Motor Corporation"},
    {active: 1, filter: 'Vehicle', code: "TRN", name: "Transcoach"},
    {active: 1, filter: 'Vehicle', code: "TRT", name: "Transteq"},
    {active: 1, filter: 'Vehicle', code: "TRY", name: "Trolley Enterprises"},
    {active: 1, filter: 'Vehicle', code: "TTR", name: "Terra Transit"},
    {active: 1, filter: 'Vehicle', code: "TTT", name: "Turtle Top"},
    {active: 1, filter: 'Vehicle', code: "USR", name: "US Railcar (formerly Colorado Railcar Manufacturing)"},
    {active: 1, filter: 'Vehicle', code: "UTD", name: "UTDC Inc."},
    {active: 1, filter: 'Vehicle', code: "VAN", name: "Van Hool N.V."},
    {active: 1, filter: 'Vehicle', code: "VOL", name: "Volvo"},
    {active: 1, filter: 'Vehicle', code: "VTH", name: "VT Halter Marine, Inc. (includes Equitable Shipyards, Inc.)"},
    {active: 1, filter: 'Vehicle', code: "WAM", name: "Westinghouse-Amrail"},
    {active: 1, filter: 'Vehicle', code: "WCI", name: "Wheeled Coach Industries Inc."},
    {active: 1, filter: 'Vehicle', code: "WDS", name: "Washburn & Doughty Associates, Inc."},
    {active: 1, filter: 'Vehicle', code: "WLH", name: "W. L. Holman Car Company"},
    {active: 1, filter: 'Vehicle', code: "WOC", name: "Wide One Corporation"},
    {active: 1, filter: 'Vehicle', code: "WTI", name: "World Trans Inc. (also Mobile-Tech Corporation)"},
    {active: 1, filter: 'Vehicle', code: "WYC", name: "Wayne Corporation (form. Wayne Manufacturing Company/WAY)"},
    {active: 1, filter: 'Vehicle', code: "ZZZ", name: "Other (Describe)"}
]

rail_cars = manufacturers.map{|x| x.merge({filter: 'RailCar'})}
locomotives = manufacturers.map{|x| x.merge({filter: 'Locomotive'})}
support_vehicles = manufacturers.map{|x| x.merge({filter: 'SupportVehicle'})}
manufacturers << rail_cars
manufacturers << locomotives
manufacturers << support_vehicles
manufacturers = manufacturers.flatten

message_templates = [
    {name: 'TamPolicy1', description: "A message is sent to the user selected as the 'TAM Group Lead', following the creation of a TAM Group, when a user clicks the 'Generate' button.", delivery_rules: 'When TAM group generated',subject: "TAM Group Generated", body: "The TAM Group: {tam_group}, has been generated for {tam_policy}. You have been designated as the group lead. You must assign metrics for the group, based on asset category and asset class/type/mode. Upon completion, you must distribute group metrics. You can access the group {link(here)}.", active: true, is_implemented: true},
    {name: 'TamPolicy2', description: "A message is sent to each user with the 'Manager' role at every organization included in a TAM Group, when a user clicks the 'Distribute' button.", delivery_rules: 'When TAM group distributed', subject: "TAM Group Distributed", body: "The TAM Group: {tam_group}, has been distributed for {tam_policy}. The TAM Group: {tam_group}, has been created in your TAM policy, performance measures section. If you are able to make changes to the performance measures, you may make any changes needed, and activate the performance measures. If you are not allowed to make changes, the performance measures will be activated automatically. You can access the performance measures {link(here)}.", active: true, is_implemented: true},
    {name: 'TamPolicy3', description: "A message is sent to the user selected as the 'TAM Group Lead', following an organization either automatically or manually activating an annual TAM Policy.", delivery_rules: 'When TAM group activated', subject: "TAM Performance Measures Activated",  body: "{organization} has activated the TAM performance measures, associated with the TAM Group: {tam_group} for {tam_policy}.You can access the {organization} performance measures {link(here)}.", active: true, is_implemented: true}
]

activities = [
    { name: 'Service Life Updates',
      description: 'Update policy replacement year for meeting mileage, condition policy rules.',
      show_in_dashboard: false,
      system_activity: true,
      frequency_quantity: 1,
      frequency_type_id: 5,
      execution_time: '01:01',
      job_name: 'AssetServiceLifeUpdateJob',
      active: true }
]

system_config_extensions = [
    {engine_name: 'transit', class_name: 'TransamAsset', extension_name: 'PolicyAware', active: true},
    {engine_name: 'transit', class_name: 'TransamAsset', extension_name: 'ReplaceableAsset', active: true}
]
if SystemConfig.transam_module_loaded? :spatial
    system_config_extensions += [
        {engine_name: 'transit', class_name: 'Facility', extension_name: 'TransamAddressLocatable', active: true},
        {engine_name: 'transit', class_name: 'ServiceVehicle', extension_name: 'TransamParentLocatable', active: true},
        {engine_name: 'transit', class_name: 'CapitalEquipment', extension_name: 'TransamParentLocatable', active: true},
        {engine_name: 'transit', class_name: 'Infrastructure', extension_name: 'TransamCoordinateLocatable', active: true},
        {engine_name: 'transit', class_name: 'AssetMapSearcher', extension_name: 'TransitAssetMapSearchable', active: true}
    ]
end

if SystemConfig.transam_module_loaded? :audit
  Audit.where(auditor_class_name: "AssetAuditor").each do |audit|
    audit.filterable_class_name = "FtaAssetCategory"
    audit.save
  end
end

merge_tables = %w{ activities rule_sets roles asset_event_types condition_estimation_types service_life_calculation_types report_types manufacturers message_templates forms system_config_extensions }

merge_tables.each do |table_name|
  puts "  Merging #{table_name}"
  data = eval(table_name)
  klass = table_name.classify.constantize
  data.each do |row|
    x = klass.new(row)
    x.save!
  end
end

puts "  Modifying labels for core roles"
Role.where(name: [:user, :manager]).update_all(label: 'Staff')
Role.find_by(name: :super_manager).update(label: 'Manager', privilege: false, role_parent_id: nil)

puts "  Merging asset_subsystems"

asset_subsystems = [
  {:name => "Transmission", :code => "TR", :asset_type => "Vehicle", :active => false},
  {:name => "Engine",       :code => "EN", :asset_type => "Vehicle", :active => false},
  {:name => "Trucks",       :code => "TR", :asset_type => "RailCar", :active => false},
  {:name => "Trucks",       :code => "TR", :asset_type => "Locomotive", :active => false}
]

asset_subsystems.each do |s|
  subsystem = AssetSubsystem.new(:name => s[:name], :description => s[:name], :active => s[:active], :code => s[:code])
  asset_type = AssetType.find_by(name: s[:asset_type])
  subsystem.asset_type = asset_type
  subsystem.save
end




puts "======= Processing TransAM Transit Reports  ======="

reports = [
  {:active => 0, :belongs_to => 'report_type', :type => "Inventory Report",
    :name => 'Useful Life Consumed Report',
    :class_name => "ServiceLifeConsumedReport",
    :view_name => "generic_chart",
    :show_in_nav => 1,
    :show_in_dashboard => 0,
    :roles => 'guest,user',
    :description => 'Displays a summary of the amount of useful life that has been consumed as a percentage of all assets.',
    :chart_type => 'column',
    :chart_options => "{is3D : true, isStacked: true, fontSize: 10, hAxis: {title: 'Percent of expected useful life consumed'}, vAxis: {title: 'Share of all assets'}}"},
  {:active => 1, :belongs_to => 'report_type', :type => "Inventory Report",
    :name => 'Asset Condition Report',
    :class_name => "AssetConditionReport",
    :view_name => "generic_chart",
    :show_in_nav => 1,
    :show_in_dashboard => 0,
    :roles => 'guest,user',
    :description => 'Displays asset counts by condition.',
    :chart_type => 'pie',
    :chart_options => '{is3D : true}',
    :exportable => true,
    :printable => true},
  {:active => 0, :belongs_to => 'report_type', :type => "Inventory Report",
    :name => 'Asset Subtype Report',
    :class_name => "AssetSubtypeReport",
    :view_name => "generic_chart",
    :show_in_nav => 1,
    :show_in_dashboard => 0,
    :roles => 'guest,user',
    :description => 'Displays asset counts by subtypes.',
    :chart_type => 'pie',
    :chart_options => '{is3D : true}'},
  {:active => 1, :belongs_to => 'report_type', :type => "Inventory Report",
    :name => 'Asset Age Report',
    :class_name => "AssetAgeReport",
    :view_name => "generic_chart",
    :show_in_nav => 1,
    :show_in_dashboard => 0,
    :roles => 'guest,user',
    :description => 'Displays asset counts by age.',
    :chart_type => 'column',
    :chart_options => "{is3D : true, isStacked : true, hAxis: {title: 'Age (years)'}, vAxis: {title: 'Count'}}",
    :exportable => true,
    :printable => true},
  {:active => 1, :belongs_to => 'report_type', :type => "Capital Needs Report",
    :name => 'Backlog Report',
    :class_name => "BacklogReport",
    :view_name => "generic_report",
    :show_in_nav => 1,
    :show_in_dashboard => 0,
    :roles => 'guest,user',
    :description => 'Determines backlog needs.'},
  {:active => 1, :belongs_to => 'report_type', :type => "Inventory Report",
    :name => 'Asset Type by Org Report',
    :class_name => "CustomSqlReport",
    :view_name => "generic_report_table",
    :show_in_nav => 0,
    :show_in_dashboard => 0,
    :roles => 'guest,user',
    :description => 'Displays a summary of asset types by agency.',
    :custom_sql => "SELECT c.short_name AS 'Org', b.name AS 'Type', COUNT(*) AS 'Count' FROM assets a LEFT JOIN asset_subtypes b ON a.asset_subtype_id = b.id LEFT JOIN organizations c ON a.organization_id = c.id GROUP BY a.organization_id, a.asset_subtype_id ORDER BY c.short_name, b.name"},
  {:active => 1, :belongs_to => 'report_type', :type => "Planning Report",
    :name => 'Revenue Vehicle Replacement Report',
    :class_name => "VehicleReplacementReport",
    :view_name => "vehicle_replacement_report",
    :show_in_nav => 1,
    :show_in_dashboard => 0,
    :roles => 'guest,user',
    :description => 'Reports the list of vehicles scheduled to be replaced.',
    :printable => true,
    :exportable => true
  },
    {:active => 1, :belongs_to => 'report_type', :type => "Planning Report",
    :name => 'State of Good Repair Report',
    :class_name => "StateOfGoodRepairReport",
    :view_name => "state_of_good_repair_report",
    :show_in_nav => 1,
    :show_in_dashboard => 0,
    :roles => 'guest,user',
    :description => 'Reports an agency\'s current State of Good Repair.',
    :printable => true,
    :exportable => true
  },
    {:active => 1, :belongs_to => 'report_type', :type => "Planning Report",
    :name => 'Disposition Report',
    :class_name => "AssetDispositionReport",
    :view_name => "asset_disposition_report",
    :show_in_nav => 1,
    :show_in_dashboard => 0,
    :roles => 'guest,user',
    :description => 'Reports Vehicles which have been disposed.',
    :printable => true,
    :exportable => true
  },
  {:active => 1, :belongs_to => 'report_type', :type => "Planning Report",
   :name => 'Asset Service Life Summary Report',
   :class_name => "AssetServiceLifeReport",
   :view_name => "generic_table_with_subreports",
   :show_in_nav => 1,
   :show_in_dashboard => 0,
   :roles => 'guest,user',
   :description => 'Reports on assets past service life',
   :printable => true,
   :exportable => true,
   :data_exportable => true,
  }
]

table_name = 'reports'
puts "  Merging #{table_name}"
data = eval(table_name)
data.each do |row|
  puts "Creating Report #{row[:name]}"
  x = Report.new(row.except(:belongs_to, :type))
  x.report_type = ReportType.find_by(:name => row[:type])
  x.save!
end

dual_fuel_types = [
    {active: true, primary_fuel_type: 'Diesel Fuel', secondary_fuel_type: 'Compressed Natural Gas'},
    {active: true, primary_fuel_type: 'Diesel Fuel', secondary_fuel_type: 'Used/Recycled Cooking Oil'},
    {active: true, primary_fuel_type: 'Diesel Fuel', secondary_fuel_type: 'Electric Propulsion Power'},
    {active: true, primary_fuel_type: 'Diesel Fuel', secondary_fuel_type: 'Electric Battery'},
    {active: true, primary_fuel_type: 'Diesel Fuel', secondary_fuel_type: 'Kerosene'},
    {active: true, primary_fuel_type: 'Diesel Fuel', secondary_fuel_type: 'Liquefied Petroleum Gas'},
    {active: true, primary_fuel_type: 'Hybrid Diesel', secondary_fuel_type: 'Compressed Natural Gas'},
    {active: true, primary_fuel_type: 'Hybrid Diesel', secondary_fuel_type: 'Used/Recycled Cooking Oil'},
    {active: true, primary_fuel_type: 'Hybrid Diesel', secondary_fuel_type: 'Electric Battery'},
    {active: true, primary_fuel_type: 'Hybrid Diesel', secondary_fuel_type: 'Electric Propulsion Power'},
    {active: true, primary_fuel_type: 'Hybrid Diesel', secondary_fuel_type: 'Kerosene'},
    {active: true, primary_fuel_type: 'Hybrid Diesel', secondary_fuel_type: 'Liquefied Petroleum Gas'},
    {active: true, primary_fuel_type: 'Gasoline', secondary_fuel_type: 'Compressed Natural Gas'},
    {active: true, primary_fuel_type: 'Gasoline', secondary_fuel_type: 'Ethanol'},
    {active: true, primary_fuel_type: 'Gasoline', secondary_fuel_type: 'Liquefied Petroleum Gas'},
    {active: true, primary_fuel_type: 'Hybrid Gasoline', secondary_fuel_type: 'Compressed Natural Gas'},
    {active: true, primary_fuel_type: 'Hybrid Gasoline', secondary_fuel_type: 'Ethanol'},
    {active: true, primary_fuel_type: 'Hybrid Gasoline', secondary_fuel_type: 'Liquefied Petroleum Gas'}
]

table_name = 'dual_fuel_types'
puts "  Merging #{table_name}"
data = eval(table_name)
data.each do |row|
  puts "Creating Dual Fuel Type #{row[:primary_fuel_type]}-#{row[:secondary_fuel_type]}"
  x = DualFuelType.new(row.except(:primary_fuel_type, :secondary_fuel_type))
  x.primary_fuel_type = FuelType.find_by(name: row[:primary_fuel_type])
  x.secondary_fuel_type = FuelType.find_by(name: row[:secondary_fuel_type])
  x.save!
end

# asset query seeds
require_relative File.join("seeds", 'asset_query_seeds')