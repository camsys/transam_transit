#encoding: utf-8
TransamCore::Engine.load_seed

# determine if we are using postgres or mysql
is_mysql = (ActiveRecord::Base.configurations[Rails.env]['adapter'] == 'mysql2')
is_sqlite = (ActiveRecord::Base.configurations[Rails.env]['adapter'] == 'sqlite3')

puts "======= Processing TransAM Transit Lookup Tables  ======="

#------------------------------------------------------------------------------
#
# Customized Lookup Tables
#
# These are the specific to TransAM Transit
#
#------------------------------------------------------------------------------

fuel_types = [
  {:active => 1, :name => 'Unknown',                        :code => 'XX', :description => 'No Fuel type specified.'},
  {:active => 1, :name => 'Biodiesel',                      :code => 'BD', :description => 'Biodiesel.'},
  {:active => 1, :name => 'Bunker Fuel',                    :code => 'BF', :description => 'Bunker Fuel.'},
  {:active => 1, :name => 'Compressed Natural Gas',         :code => 'CN', :description => 'Compressed Natutral Gas.'},
  {:active => 1, :name => 'Diesel Fuel',                    :code => 'DF', :description => 'Diesel Fuel.'},
  {:active => 1, :name => 'Dual Fuel',                      :code => 'DU', :description => 'Dual Fuel.'},
  {:active => 1, :name => 'Electric Battery',               :code => 'EB', :description => 'Electric Battery.'},
  {:active => 1, :name => 'Electric Propulsion',            :code => 'EP', :description => 'Electric Propulsion.'},
  {:active => 1, :name => 'Ethanol',                        :code => 'ET', :description => 'Ethanol.'},
  {:active => 1, :name => 'Gasoline',                       :code => 'GA', :description => 'Gasoline.'},
  {:active => 1, :name => 'Hybrid Diesel',                  :code => 'HD', :description => 'Hybrid Diesel.'},
  {:active => 1, :name => 'Hybrid Gasoline',                :code => 'HG', :description => 'Hybrid Gasoline.'},
  {:active => 1, :name => 'Hydrogen',                       :code => 'HY', :description => 'Hydrogen.'},
  {:active => 1, :name => 'Kerosene',                       :code => 'KE', :description => 'Kerosene.'},
  {:active => 1, :name => 'Liquefied Natural Gas',          :code => 'LN', :description => 'Liquefied Natural Gas.'},
  {:active => 1, :name => 'Liquefied Petroleum Gas',        :code => 'LP', :description => 'Liquefied Petroleum Gas.'},
  {:active => 1, :name => 'Methanol',                       :code => 'MT', :description => 'Methanol.'},
  {:active => 1, :name => 'Other',                          :code => 'OR', :description => 'Other.'}
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
  {:active => 1, :name => 'Unknown',          :code => 'X', :description => 'No Vehicle usage specified.'},
  {:active => 1, :name => 'Revenue vehicle',  :code => 'R', :description => 'Revenue vehicle.'},
  {:active => 1, :name => 'Support Vehicle',  :code => 'S', :description => 'Support vehicle.'},
  {:active => 1, :name => 'Van Pool',         :code => 'V', :description => 'Van Pool.'},
  {:active => 1, :name => 'Paratransit',      :code => 'P', :description => 'Paratransit.'},
  {:active => 1, :name => 'Spare Inventory',  :code => 'I', :description => 'Spare Inventory.'}
]
fta_mode_types = [
  {:active => 1, :name => 'Unknown',                      :code => 'XX', :description => 'No FTA mode type specified.'},
  {:active => 1, :name => 'Aerial Tramway',               :code => 'TR', :description => 'Aerial Tramway.'},
  {:active => 1, :name => 'Bus',                          :code => 'MB', :description => 'Bus.'},
  {:active => 1, :name => 'Bus Rapid Transit',            :code => 'RB', :description => 'Bus rapid transit.'},
  {:active => 1, :name => 'Commuter Bus',                 :code => 'CB', :description => 'Commuter bus.'},
  {:active => 1, :name => 'Demand Response',              :code => 'DR', :description => 'Demand Response.'},
  {:active => 1, :name => 'Ferry Boat',                   :code => 'FB', :description => 'Ferryboat.'},
  {:active => 1, :name => 'Jitney',                       :code => 'JT', :description => 'Jitney.'},
  {:active => 1, :name => 'Publico',                      :code => 'PB', :description => 'Publico.'},
  {:active => 1, :name => 'Trolley Bus',                  :code => 'TB', :description => 'Trolleybus.'},
  {:active => 1, :name => 'Van Pool',                     :code => 'VP', :description => 'Vanpool.'},
  {:active => 1, :name => 'Alaska Railroad',              :code => 'AR', :description => 'Alaska Railroad.'},
  {:active => 1, :name => 'Monorail/Automated Guideway Transit',  :code => 'MG', :description => 'Monorail/Automated guideway transit.'},
  {:active => 1, :name => 'Cable Car',                    :code => 'CC', :description => 'Cable car.'},
  {:active => 1, :name => 'Commuter Rail',                :code => 'CR', :description => 'Commuter rail.'},
  {:active => 1, :name => 'Heavy Rail',                   :code => 'HR', :description => 'Heavy rail.'},
  {:active => 1, :name => 'Inclined Plane',               :code => 'IP', :description => 'Inclined plane.'},
  {:active => 1, :name => 'Light Rail',                   :code => 'LR', :description => 'Light rail.'},
  {:active => 1, :name => 'Street Car',                    :code => 'SR', :description => 'Streetcar.'},
  {:active => 1, :name => 'Hybrid Rail',                  :code => 'HR', :description => 'Hybrid rail.'}
]
fta_service_types = [
  {:active => 1, :name => 'Unknown',                      :code => 'XX', :description => 'FTA Service type not specified.'},
  {:active => 1, :name => 'Directly Operated',            :code => 'DO', :description => 'Directly Operated.'},
  {:active => 1, :name => 'Purchased Transportation',     :code => 'PT', :description => 'Purchased Transportation.'}
]
fta_agency_types = [
  {:active => 1, :name => 'Public Agency (Not DOT or Tribal)',      :description => 'Public Agency (Not DOT or Tribal).'},
  {:active => 1, :name => 'Public Agency (State DOT)',    :description => 'Public Agency (State DOT).'},
  {:active => 1, :name => 'Public Agency (Tribal)',       :description => 'Public Agency (Tribal).'},
  {:active => 1, :name => 'Private (Not for profit)',     :description => 'Private (Not for profit).'}
]
fta_service_area_types = [
  {:active => 1, :name => 'County / Independent city',          :description => 'County / Independent city.'},
  {:active => 1, :name => 'Multi-county / Independent city',    :description => 'Multi-county / Independent city.'},
  {:active => 1, :name => 'Multi-state',                        :description => 'Multi-state.'},
  {:active => 1, :name => 'Municipality',                       :description => 'Municipality.'},
  {:active => 1, :name => 'Reservation',                        :description => 'Reservation.'},
  {:active => 1, :name => 'Other',                              :description => 'Other.'}
]

fta_funding_types = [
  {:active => 1, :name => 'Unknown',                        :code => 'XX',    :description => 'FTA funding type not specified.'},
  {:active => 1, :name => 'Urbanized Area Formula Program', :code => 'UA',    :description => 'UA -Urbanized Area Formula Program.'},
  {:active => 1, :name => 'Other Federal funds',            :code => 'OF',    :description => 'OF-Other Federal funds.'},
  {:active => 1, :name => 'Non-Federal public funds',       :code => 'NFPA',  :description => 'NFPA-Non-Federal public funds.'},
  {:active => 1, :name => 'Non-Federal private funds',      :code => 'NFPE',  :description => 'NFPE-Non-Federal private funds.'}
]

fta_funding_source_types = [
  {:active => 1, :name => 'Unknown', :description => 'FTA funding source not specified.'},
  {:active => 1, :name => '5307', :description => 'Urbanized area formula program.'},
  {:active => 1, :name => '5309', :description => 'Bus and bus facilities.'},
  {:active => 1, :name => '5310', :description => 'Transporation for elderly persons and persons with disabilities.'},
  {:active => 1, :name => '5311', :description => 'Formula grants for other than urbanized areas.'},
  {:active => 1, :name => '5316', :description => 'Job access and reverse commute.'},
  {:active => 1, :name => '5317', :description => 'New freedom program.'},
  {:active => 1, :name => '5320', :description => 'Transit in parks program.'},
  {:active => 1, :name => '5339', :description => 'Alternatives analysis.'},
  # codes that may have been entered directly by agencies:
  {:active => 1, :name => 'CMAQ', :description => 'Congestion Mitigation and Air Quality Improvement Program.'},
  {:active => 1, :name => 'Flex', :description => 'STP, CMAQ, TE, or TCSP.'},
  {:active => 1, :name => 'ARRA', :description => 'Urbanized area formula program (Amer. Recovery & Reinvestment Act)'}

]

fta_ownership_types = [
  {:active => 1, :name => 'Unknown',                              :code => 'XX',    :description => 'FTA ownership type not specified.'},
  {:active => 1, :name => 'Lease purchase by a public agency',    :code => 'LPPA',  :description => 'Leased under lease purchase agreement by a public agency.'},
  {:active => 1, :name => 'Lease purchase by a private entity',   :code => 'LPPE',  :description => 'Leased under lease purchase agreement by a private entity.'},
  {:active => 1, :name => 'Lease or borrowed by a public agency', :code => 'LRPA',  :description => 'Leased or borrowed from related parties by a public agency.'},
  {:active => 1, :name => 'Lease or borrowed by a private agency',:code => 'LRPE',  :description => 'Leased or borrowed from related parties by a private entity.'},
  {:active => 1, :name => 'Owned outright by a public agency',    :code => 'OOPA',  :description => 'Owned outright by a public agency (includes safe-harbor leasing agreements where only the tax title is sold).'},
  {:active => 1, :name => 'Owned outright by a private entity',   :code => 'OOPE',  :description => 'Owned outright by a private entity (includes safe-harbor leasing agreements where only the tax title is sold).'},
  {:active => 1, :name => 'True lease by a public agency',        :code => 'TLPA',  :description => 'True lease by a public agency.'},
  {:active => 1, :name => 'True lease by a private entity',       :code => 'TLPE',  :description => 'True lease by a private entity.'},
  {:active => 1, :name => 'Other',                                :code => 'OR',  :description => 'Other.'}
]

fta_vehicle_types = [
  {:active => 1, :name => 'Unknown',                :code => 'XX', :description => 'Vehicle type not specified.'},
  {:active => 1, :name => 'Articulated Bus',        :code => 'AB',  :description => 'Articulated Bus.'},
  {:active => 1, :name => 'Automated Guideway Vehicle',        :code => 'AG',  :description => 'Automated Guideway Vehicle.'},
  {:active => 1, :name => 'Automobile',             :code => 'AO',  :description => 'Automobile.'},
  {:active => 1, :name => 'Over-The-Road Bus',      :code => 'BR',  :description => 'Over-The-Road Bus.'},
  {:active => 1, :name => 'Bus',                    :code => 'BU',  :description => 'Bus.'},
  {:active => 1, :name => 'Cable Car',              :code => 'CC',  :description => 'Cable Car.'},
  {:active => 1, :name => 'Cutaway',                :code => 'CU',  :description => 'Cutaway.'},
  {:active => 1, :name => 'Double Decker Bus',      :code => 'DB',  :description => 'Double Decker Bus.'},
  {:active => 1, :name => 'Ferry Boat',             :code => 'FB',  :description => 'Ferryboat.'},
  {:active => 1, :name => 'Heavy Rail Passenger Car',  :code => 'HR',  :description => 'Heavy Rail Passenger Car.'},
  {:active => 1, :name => 'Inclined Plane Vehicle', :code => 'IP',  :description => 'Inclined Plane Vehicle.'},
  {:active => 1, :name => 'Light Rail Vehicle', :code => 'LR',  :description => 'Light Rail Vehicle.'},
  {:active => 1, :name => 'Monorail/Automated Guideway', :code => 'MO',  :description => 'Monorail/Automated Guideway.'},
  {:active => 1, :name => 'Mini Van',               :code => 'MV',  :description => 'Minivan.'},
  {:active => 1, :name => 'Commuter Rail Locomotive',                   :code => 'RL',  :description => 'Commuter Rail Locomotive.'},
  {:active => 1, :name => 'Commuter Rail Passenger Coach',              :code => 'RP',  :description => 'Commuter Rail Passenger Coach.'},
  {:active => 1, :name => 'Commuter Rail Self-Propelled Passenger Car', :code => 'RS',  :description => 'Commuter Rail Self-Propelled Passenger Car.'},
  {:active => 1, :name => 'School Bus',             :code => 'SB',  :description => 'School Bus.'},
  {:active => 1, :name => 'Sports Utility Vehicle', :code => 'SV',  :description => 'Sports Utility Vehicle.'},
  {:active => 1, :name => 'Trolley Bus',            :code => 'TB',  :description => 'Trolley Bus.'},
  {:active => 1, :name => 'Aerial Tramway',         :code => 'TR',  :description => 'Aerial Tramway.'},
  {:active => 1, :name => 'Taxicab Sedan',          :code => 'TS',  :description => 'Taxicab Sedan.'},
  {:active => 1, :name => 'Taxicab Van',            :code => 'TV',  :description => 'Taxicab Van.'},
  {:active => 1, :name => 'Taxicab Station Wagon',  :code => 'TW',  :description => 'Taxicab Station Wagon.'},
  {:active => 1, :name => 'Van',                    :code => 'VN',  :description => 'Van.'},
  {:active => 1, :name => 'Vintage Trolley/Streetcar',:code => 'VT',  :description => 'Vintage Trolley/Streetcar.'}
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

service_types = [
  {:active => 1, :name => 'Urban',            :code => 'URB',   :description => 'Operates in an urban area.'},
  {:active => 1, :name => 'Rural',            :code => 'RUR',   :description => 'Operates in a rural area.'},
  {:active => 1, :name => 'Shared Ride',      :code => 'SHR',   :description => 'Provides shared ride services.'},
  {:active => 1, :name => 'Intercity Bus',    :code => 'ICB',   :description => 'Provides intercity bus services.'},
  {:active => 1, :name => 'Intercity Rail',   :code => 'ICR',   :description => 'Provides intercity rail services.'},
  {:active => 1, :name => '5310',             :code => '5310',  :description => 'Provides 5310 services.'},
  {:active => 1, :name => 'NFRDM',            :code => 'NFRDM', :description => 'Provides NFRDM services.'},
  {:active => 1, :name => 'WTW',              :code => 'WTW',   :description => 'Provides WTW services.'},
  {:active => 1, :name => 'Other',            :code => 'OTH',   :description => 'Provides other services.'}
]

asset_types = [
  {:active => 1, :name => 'Vehicle',          :description => 'Vehicle',              :class_name => 'Vehicle',           :map_icon_name => "redIcon",      :display_icon_name => "fa fa-bus", :new_inventory_template_name => 'new_inventory_template_v_3_4.xlsx'},
  {:active => 1, :name => 'Rail Car',         :description => 'Rail Car',             :class_name => 'RailCar',           :map_icon_name => "orangeIcon",   :display_icon_name => "fa travelcon travelcon-subway", :new_inventory_template_name => 'new_inventory_template_v_3_4.xlsx'},
  {:active => 1, :name => 'Locomotive',       :description => 'Locomotive',           :class_name => 'Locomotive',        :map_icon_name => "greenIcon",    :display_icon_name => "fa travelcon travelcon-train", :new_inventory_template_name => 'new_inventory_template_v_3_4.xlsx'},
  {:active => 1, :name => 'Transit Facility', :description => 'Transit Facility',     :class_name => 'TransitFacility',   :map_icon_name => "greenIcon",    :display_icon_name => "fa fa-building-o", :new_inventory_template_name => 'new_facility_inventory_template_v_1_0.xlsx'},
  {:active => 1, :name => 'Support Facility', :description => 'Support Facility',     :class_name => 'SupportFacility',   :map_icon_name => "blueIcon",     :display_icon_name => "fa fa-building", :new_inventory_template_name => 'new_facility_inventory_template_v_1_0.xlsx'},
  {:active => 1, :name => 'Bridge/Tunnel',    :description => 'Bridges and Tunnels',  :class_name => 'BridgeTunnel',      :map_icon_name => "redIcon",      :display_icon_name => "fa fa-square", :new_inventory_template_name => 'new_facility_inventory_template_v_1_0.xlsx'},
  {:active => 1, :name => 'Support Vehicle',  :description => 'Support Vehicle',      :class_name => 'SupportVehicle',    :map_icon_name => "redIcon",      :display_icon_name => "fa fa-truck", :new_inventory_template_name => 'new_inventory_template_v_3_4.xlsx'}
]

file_content_types = [
  {:active => 1, :name => 'New Inventory',      :class_name => 'NewInventoryFileHandler',     :builder_name => "NewInventoryTemplateBuilder",   :description => 'Worksheet contains new inventory to be loaded into TransAM.'},
  {:active => 1, :name => 'Status Updates',     :class_name => 'StatusUpdatesFileHandler',    :builder_name => "StatusUpdatesTemplateBuilder",  :description => 'Worksheet records condition, usage, and operational updates for exisiting inventory.'},
  {:active => 1, :name => 'Disposition Updates',  :class_name => 'DispositionUpdatesFileHandler', :builder_name => "DispositionUpdatesTemplateBuilder", :description => 'Worksheet contains final disposition updates for existing inventory.'}
]

service_provider_types = [
  {:active => 1,  :name => 'Rural General Public Transit Service Provider', :code => 'RU-20', :description => 'Rural General Public Transit Service provider.'},
  {:active => 1,  :name => 'Intercity Bus Service Provider',                :code => 'RU-21', :description => 'Intercity Bus Service provider.'},
  {:active => 1,  :name => 'Rural Recipient Reporting Separately',          :code => 'RU-22', :description => 'Rural Recipient Reporting Separately.'},
  {:active => 1,  :name => 'Urban Recipient',                               :code => 'RU-23', :description => 'Urban Recipient.'}
]

purchase_method_types = [
  {:active => 1,  :name => 'Method 1', :code => 'M1', :description => 'Method 1.'},
  {:active => 1,  :name => 'Method 2', :code => 'M2', :description => 'Method 2.'}
]
vehicle_storage_method_types = [
  {:active => 1,  :name => 'Unknown',:code => 'X', :description => 'Vehicle storage method not supplied.'},
  {:active => 1,  :name => 'Indoors', :code => 'I', :description => 'Vehicle is always stored indoors.'},
  {:active => 1,  :name => 'Outdoors', :code => 'O', :description => 'Vehicle is always stored outdoors.'},
  {:active => 1,  :name => 'Indoor/Outdoor', :code => 'B', :description => 'Vehicle is stored both indoors and outdoors.'}
]


replace_tables = %w{ fuel_types vehicle_features vehicle_usage_codes fta_mode_types fta_agency_types fta_service_area_types
  fta_service_types fta_funding_types fta_ownership_types fta_vehicle_types fta_funding_source_types facility_capacity_types 
  facility_features service_types asset_types 
  file_content_types service_provider_types purchase_method_types
  vehicle_storage_method_types
  }

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

require_relative File.join("seeds", 'team_ali_code_seeds') # TEAM ALI Codes are seeded from a separate file

# These tables are merged with core tables

asset_event_types = [
  {:active => 1, :name => 'Update the mileage',       :display_icon_name => "fa fa-road",       :description => 'Mileage Update',       :class_name => 'MileageUpdateEvent',      :job_name => 'AssetMileageUpdateJob'},
  {:active => 1, :name => 'Update the location',       :display_icon_name => "fa fa-map-marker",       :description => 'Location Update',       :class_name => 'LocationUpdateEvent',      :job_name => 'AssetLocationUpdateJob'},
  {:active => 1, :name => 'Update the operations metrics',      :display_icon_name => "fa fa-calculator",        :description => 'Operations Update',:class_name => 'OperationsUpdateEvent',     :job_name => 'AssetOperationsUpdateJob'},
  {:active => 1, :name => 'Update the use metrics',           :display_icon_name => "fa fa-line-chart",      :description => 'Usage Update',     :class_name => 'UsageUpdateEvent',          :job_name => 'AssetUsageUpdateJob'},
  {:active => 1, :name => 'Update the storage method',       :display_icon_name => "fa fa-star-half-o",       :description => 'Storage Method',       :class_name => 'StorageMethodUpdateEvent',      :job_name => 'AssetStorageMethodUpdateJob'},
  {:active => 1, :name => 'Update the usage codes',       :display_icon_name => "fa fa-star-half-o",       :description => 'Usage Codes',       :class_name => 'UsageCodesUpdateEvent',      :job_name => 'AssetUsageCodesUpdateJob'}
]

condition_estimation_types = [
  {:active => 1, :name => 'TERM',           :class_name => 'TermEstimationCalculator',          :description => 'Asset condition is estimated using FTA TERM approximations.'}
]
service_life_calculation_types = [
  {:active => 1, :name => 'Age and Mileage',   :class_name => 'ServiceLifeAgeAndMileage',   :description => 'Calculate the replacement year based on the age of the asset or mileage whichever minimizes asset life.'}
]

merge_tables = %w{ asset_event_types condition_estimation_types service_life_calculation_types }

merge_tables.each do |table_name|
  puts "  Merging #{table_name}"
  data = eval(table_name)
  klass = table_name.classify.constantize
  data.each do |row|
    x = klass.new(row)
    x.save!
  end
end


asset_subtypes = [
  {:active => 1, :ali_code => '01', :belongs_to => 'asset_type',  :type => 'Vehicle', :name => 'Bus Std 40 FT', :image => 'bus_std_40_ft.png', :description => 'Bus Std 40 FT'},
  {:active => 1, :ali_code => '02', :belongs_to => 'asset_type',  :type => 'Vehicle', :name => 'Bus Std 35 FT', :image => 'bus_std_35_ft.png', :description => 'Bus Std 35 FT'},
  {:active => 1, :ali_code => '03', :belongs_to => 'asset_type',  :type => 'Vehicle', :name => 'Bus 30 FT',     :image => 'bus_std_30_ft.png', :description => 'Bus 30 FT'},
  {:active => 1, :ali_code => '04', :belongs_to => 'asset_type',  :type => 'Vehicle', :name => 'Bus < 30 FT',   :image => 'bus_std_lt_30_ft.jpg', :description => 'Bus < 30 FT'},
  {:active => 1, :ali_code => '05', :belongs_to => 'asset_type',  :type => 'Vehicle', :name => 'Bus School',   :image => 'bus_school.jpg',     :description => 'Bus School'},
  {:active => 1, :ali_code => '06', :belongs_to => 'asset_type',  :type => 'Vehicle', :name => 'Bus Articulated', :image => 'bus_articulated.jpg',             :description => 'Bus Articulated'},
  {:active => 1, :ali_code => '07', :belongs_to => 'asset_type',  :type => 'Vehicle', :name => 'Bus Commuter/Suburban', :image => 'bus_commuter.png',       :description => 'Bus Commuter/Suburban'},
  {:active => 1, :ali_code => '08', :belongs_to => 'asset_type',  :type => 'Vehicle', :name => 'Bus Intercity', :image => 'bus_intercity.jpg',               :description => 'Bus Intercity'},
  {:active => 1, :ali_code => '09', :belongs_to => 'asset_type',  :type => 'Vehicle', :name => 'Bus Trolley Std', :image => 'trolley_std.jpg',             :description => 'Bus Trolley Std'},
  {:active => 1, :ali_code => '10', :belongs_to => 'asset_type',  :type => 'Vehicle', :name => 'Bus Trolley Articulated',:image => 'trolley_articulated.png',      :description => 'Bus Trolley Articulated'},
  {:active => 1, :ali_code => '11', :belongs_to => 'asset_type',  :type => 'Vehicle', :name => 'Bus Double Deck', :image => 'bus_double_deck.jpg',             :description => 'Bus Double Deck'},
  {:active => 1, :ali_code => '14', :belongs_to => 'asset_type',  :type => 'Vehicle', :name => 'Bus Dual Mode',                  :image => 'bus_dual_mode.png',                :description => 'Bus Dual Mode'},
  {:active => 1, :ali_code => '15', :belongs_to => 'asset_type',  :type => 'Vehicle', :name => 'Van',                            :image => 'van.jpg',                        :description => 'Van'},
  {:active => 1, :ali_code => '16', :belongs_to => 'asset_type',  :type => 'Vehicle', :name => 'Sedan/Station Wagon',            :image => 'sedan.jpg',         :description => 'Sedan/Station Wagon'},
  {:active => 1, :ali_code => '33', :belongs_to => 'asset_type',  :type => 'Vehicle', :name => 'Ferry Boat',                     :image => 'ferry.jpg',                  :description => 'Ferry Boat'},

  {:active => 1, :ali_code => '20', :belongs_to => 'asset_type',  :type => 'Rail Car', :name => 'Light Rail Car',                :image => 'light_rail.png',            :description => 'Light Rail Car'},
  {:active => 1, :ali_code => '21', :belongs_to => 'asset_type',  :type => 'Rail Car', :name => 'Heavy Rail Car',                :image => 'heavy_rail.png',             :description => 'Heavy Rail Car'},
  {:active => 1, :ali_code => '22', :belongs_to => 'asset_type',  :type => 'Rail Car', :name => 'Commuter Rail Self Propelled (Elec)',:image => 'commuter_rail_self_propelled_elec.png',    :description => 'Commuter Rail Self Propelled (Elec)'},
  {:active => 1, :ali_code => '28', :belongs_to => 'asset_type',  :type => 'Rail Car', :name => 'Commuter Rail Self Propelled (Diesel)', :image => 'commuter_rail_self_propelled_diesel.png', :description => 'Commuter Rail Self Propelled (Diesel)'},
  {:active => 1, :ali_code => '23', :belongs_to => 'asset_type',  :type => 'Rail Car', :name => 'Commuter Rail Car Trailer',     :image => 'commuter_rail_car_trailer.png',             :description => 'Commuter Rail Car Trailer'},
  {:active => 1, :ali_code => '32', :belongs_to => 'asset_type',  :type => 'Rail Car', :name => 'Incline Railway Car',           :image => 'inclined_plane.jpg',        :description => 'Commuter Rail Car Trailer'},
  {:active => 1, :ali_code => '30', :belongs_to => 'asset_type',  :type => 'Rail Car', :name => 'Cable Car',                     :image => 'cable_car.png',                  :description => 'Commuter Rail Car Trailer'},

  {:active => 1, :ali_code => '24', :belongs_to => 'asset_type',  :type => 'Locomotive', :name => 'Commuter Locomotive Diesel',  :image => 'diesel_locomotive.jpg', :description => 'Commuter Locomotive'},
  {:active => 1, :ali_code => '25', :belongs_to => 'asset_type',  :type => 'Locomotive', :name => 'Commuter Locomotive Electric',:image => 'electric_locomotive.jpg', :description => 'Commuter Locomotive'},

  {:active => 1, :ali_code => '10', :belongs_to => 'asset_type',  :type => 'Transit Facility', :name => 'Bus Shelter',           :image => 'bus_shelter.png', :description => 'Bus Shelter'},
  {:active => 1, :ali_code => '02', :belongs_to => 'asset_type',  :type => 'Transit Facility', :name => 'Bus Station',           :image => 'bus_station.png', :description => 'Bus Station'},
  {:active => 1, :ali_code => '02', :belongs_to => 'asset_type',  :type => 'Transit Facility', :name => 'Commuter Rail Station', :image => 'commuter_rail_station.png', :description => 'Commuter Rail Station'},
  {:active => 1, :ali_code => '05', :belongs_to => 'asset_type',  :type => 'Transit Facility', :name => 'Ferry Dock',            :image => 'ferry_dock.png', :description => 'Ferry Dock'},
  {:active => 1, :ali_code => '02', :belongs_to => 'asset_type',  :type => 'Transit Facility', :name => 'Heavy Rail Station',    :image => 'heavy_rail_station.png', :description => 'Heavy Rail Station'},
  {:active => 1, :ali_code => '03', :belongs_to => 'asset_type',  :type => 'Transit Facility', :name => 'Intermodal Terminal',   :image => 'intermodal_terminal.png', :description => 'Intermodal Terminal'},
  {:active => 1, :ali_code => '02', :belongs_to => 'asset_type',  :type => 'Transit Facility', :name => 'Light Rail Station',    :image => 'light_rail_station.png', :description => 'Light Rail Station'},
  {:active => 1, :ali_code => '04', :belongs_to => 'asset_type',  :type => 'Transit Facility', :name => 'Park and Ride Lot',     :image => 'park_and_ride_lot.png', :description => 'Park and Ride Lot'},
  {:active => 1, :ali_code => '04', :belongs_to => 'asset_type',  :type => 'Transit Facility', :name => 'Parking Garage',        :image => 'parking_garage.png', :description => 'Parking Garage'},
  {:active => 1, :ali_code => '04', :belongs_to => 'asset_type',  :type => 'Transit Facility', :name => 'Parking Lot',           :image => 'parking_lot.png', :description => 'Parking Lot'},

  {:active => 1, :ali_code => '01', :belongs_to => 'asset_type',  :type => 'Support Facility', :name => 'Administration Building',         :image => 'administration_building.png', :description => 'Administration Building'},
  {:active => 1, :ali_code => '02', :belongs_to => 'asset_type',  :type => 'Support Facility', :name => 'Bus Maintenance Facility',        :image => 'bus_maintenance_facility.png', :description => 'Bus Maintenance Facility'},
  {:active => 1, :ali_code => '02', :belongs_to => 'asset_type',  :type => 'Support Facility', :name => 'Bus Parking Facility',            :image => 'bus_parking_facility.png', :description => 'Bus Parking Facility'},
  {:active => 1, :ali_code => '02', :belongs_to => 'asset_type',  :type => 'Support Facility', :name => 'Bus Turnaround Facility',         :image => 'bus_turnaround_facility.png', :description => 'Bus Turnaround Facility'},
  {:active => 1, :ali_code => '02', :belongs_to => 'asset_type',  :type => 'Support Facility', :name => 'Heavy Rail Maintenance Facility', :image => 'heavy_rail_maintenance_facility.png', :description => 'Heavy Rail Maintenance Facility'},
  {:active => 1, :ali_code => '02', :belongs_to => 'asset_type',  :type => 'Support Facility', :name => 'Light Rail Maintenance Facility', :image => 'light_rail_maintenance_facility.png', :description => 'Light Rail Maintenance Facility'},
  {:active => 1, :ali_code => '02', :belongs_to => 'asset_type',  :type => 'Support Facility', :name => 'Storage Yard',                    :image => 'storage_yard.png', :description => 'Storage Yard'},

  {:active => 1, :ali_code => '11', :belongs_to => 'asset_type',  :type => 'Support Vehicle',  :name => 'Van',                            :image => 'van.jpg',           :description => 'Van'},
  {:active => 1, :ali_code => '11', :belongs_to => 'asset_type',  :type => 'Support Vehicle',  :name => 'Tow Truck',                      :image => 'tow_truck.jpg',           :description => 'Tow Truck'},
  {:active => 1, :ali_code => '11', :belongs_to => 'asset_type',  :type => 'Support Vehicle',  :name => 'Sedan/Station Wagon',            :image => 'sedan.jpg',         :description => 'Sedan/Station Wagon'},
  {:active => 1, :ali_code => '11', :belongs_to => 'asset_type',  :type => 'Support Vehicle',  :name => 'Pickup Truck',            :image => 'pickup_truck.png',               :description => 'Pickup/Utility Truck'}

]

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

puts "======= Processing TransAM Transit Reports  ======="

reports = [
  {:active => 1, :belongs_to => 'report_type', :type => "Inventory Report",
    :name => 'Useful Life Consumed Report',
    :class_name => "ServiceLifeConsumedReport",
    :view_name => "generic_chart",
    :show_in_nav => 1,
    :show_in_dashboard => 1,
    :roles => 'user,manager',
    :description => 'Displays a summary of the amount of useful life that has been consumed as a percentage of all assets.',
    :chart_type => 'column',
    :chart_options => "{is3D : true, isStacked: true, fontSize: 10, hAxis: {title: 'Percent of expected useful life consumed'}, vAxis: {title: 'Share of all assets'}}"},
  {:active => 1, :belongs_to => 'report_type', :type => "Inventory Report",
    :name => 'Asset Condition Report',
    :class_name => "AssetConditionReport",
    :view_name => "generic_chart",
    :show_in_nav => 1,
    :show_in_dashboard => 0,
    :roles => 'user,manager',
    :description => 'Displays asset counts by condition.',
    :chart_type => 'pie',
    :chart_options => '{is3D : true}'},
  {:active => 1, :belongs_to => 'report_type', :type => "Inventory Report",
    :name => 'Asset Subtype Report',
    :class_name => "AssetSubtypeReport",
    :view_name => "generic_chart",
    :show_in_nav => 1,
    :show_in_dashboard => 0,
    :roles => 'user,manager',
    :description => 'Displays asset counts by subtypes.',
    :chart_type => 'pie',
    :chart_options => '{is3D : true}'},
  {:active => 1, :belongs_to => 'report_type', :type => "Inventory Report",
    :name => 'Asset Age Report',
    :class_name => "AssetAgeReport",
    :view_name => "generic_chart",
    :show_in_nav => 1,
    :show_in_dashboard => 0,
    :roles => 'user,manager',
    :description => 'Displays asset counts by age.',
    :chart_type => 'column',
    :chart_options => "{is3D : true, isStacked : true, hAxis: {title: 'Age (years)'}, vAxis: {title: 'Count'}}"},
  {:active => 1, :belongs_to => 'report_type', :type => "Capital Needs Report",
    :name => 'Backlog Report',
    :class_name => "BacklogReport",
    :view_name => "generic_report",
    :show_in_nav => 1,
    :show_in_dashboard => 0,
    :roles => 'user,manager',
    :description => 'Determines backlog needs.'},
  {:active => 1, :belongs_to => 'report_type', :type => "Inventory Report",
    :name => 'Asset Type by Org Report',
    :class_name => "CustomSqlReport",
    :view_name => "generic_report_table",
    :show_in_nav => 0,
    :show_in_dashboard => 0,
    :roles => 'user,manager',
    :description => 'Displays a sumamry of asset types by agency.',
    :custom_sql => "SELECT c.short_name AS 'Org', b.name AS 'Type', COUNT(*) AS 'Count' FROM assets a LEFT JOIN asset_subtypes b ON a.asset_subtype_id = b.id LEFT JOIN organizations c ON a.organization_id = c.id GROUP BY a.organization_id, a.asset_subtype_id ORDER BY c.short_name, b.name"}
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

