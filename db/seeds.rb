#encoding: utf-8

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
  # Rural Reporting Modes
  {:active => 1, :name => 'Unknown',                      :code => 'XX', :description => 'No FTA mode type specified.'},
  {:active => 1, :name => 'Bus',                          :code => 'MB', :description => 'Bus.'},
  {:active => 1, :name => 'Commuter Bus',                 :code => 'CB', :description => 'Commuter bus.'},
  {:active => 1, :name => 'Demand Response',              :code => 'DR', :description => 'Demand Response.'},
  {:active => 1, :name => 'Ferry Boat',                   :code => 'FB', :description => 'Ferryboat.'},
  {:active => 1, :name => 'Taxi',                         :code => 'TX', :description => 'Taxi.'},
  {:active => 1, :name => 'Vanpool',                      :code => 'VP', :description => 'Vanpool.'},
  {:active => 1, :name => 'Aerial Tramway',               :code => 'TR', :description => 'Aerial Tramway.'},
  {:active => 1, :name => 'Bus Rapid Transit',            :code => 'RB', :description => 'Bus rapid transit.'},
  {:active => 1, :name => 'Other',                        :code => 'OR', :description => 'Other.'}
  # Urban Reporting Modes
  #{:active => 1, :name => 'Jitney',                       :code => 'JT', :description => 'Jitney.'},
  #{:active => 1, :name => 'Publico',                      :code => 'PB', :description => 'Publico.'},
  #{:active => 1, :name => 'Trolley Bus',                  :code => 'TB', :description => 'Trolleybus.'},
  #{:active => 1, :name => 'Alaska Railroad',              :code => 'AR', :description => 'Alaska Railroad.'},
  #{:active => 1, :name => 'Monorail/Automated Guideway Transit',  :code => 'MG', :description => 'Monorail/Automated guideway transit.'},
  #{:active => 1, :name => 'Cable Car',                    :code => 'CC', :description => 'Cable car.'},
  #{:active => 1, :name => 'Commuter Rail',                :code => 'CR', :description => 'Commuter rail.'},
  #{:active => 1, :name => 'Heavy Rail',                   :code => 'HR', :description => 'Heavy rail.'},
  #{:active => 1, :name => 'Inclined Plane',               :code => 'IP', :description => 'Inclined plane.'},
  #{:active => 1, :name => 'Light Rail',                   :code => 'LR', :description => 'Light rail.'},
  #{:active => 1, :name => 'Street Car',                    :code => 'SR', :description => 'Streetcar.'},
  #{:active => 1, :name => 'Hybrid Rail',                  :code => 'HR', :description => 'Hybrid rail.'}
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
  {:active => 1, :name => 'County/Independent city',          :description => 'County / Independent city.'},
  {:active => 1, :name => 'Multi-county/Independent city',    :description => 'Multi-county / Independent city.'},
  {:active => 1, :name => 'Multi-state',                      :description => 'Multi-state.'},
  {:active => 1, :name => 'Municipality',                     :description => 'Municipality.'},
  {:active => 1, :name => 'Reservation',                      :description => 'Reservation.'},
  {:active => 1, :name => 'Other',                            :description => 'Other.'}
]

fta_funding_types = [
  {:active => 1, :name => 'Unknown',                        :code => 'XX',    :description => 'FTA funding type not specified.'},
  {:active => 1, :name => 'Urbanized Area Formula Program', :code => 'UA',    :description => 'UA -Urbanized Area Formula Program.'},
  {:active => 1, :name => 'Other Federal funds',            :code => 'OF',    :description => 'OF-Other Federal funds.'},
  {:active => 1, :name => 'Non-Federal public funds',       :code => 'NFPA',  :description => 'NFPA-Non-Federal public funds.'},
  {:active => 1, :name => 'Non-Federal private funds',      :code => 'NFPE',  :description => 'NFPE-Non-Federal private funds.'}
]

fta_ownership_types = [
  # Rural Reporting Ownership Types
  {:active => 1, :name => 'Unknown',                                      :code => 'XX',    :description => 'FTA ownership type not specified.'},
  {:active => 1, :name => 'Owned by Service Provider',                    :code => 'OSP',  :description => 'Owned by Service Provider.'},
  {:active => 1, :name => 'Owned by Public Agency for Service Provider',  :code => 'OPA',  :description => 'Owned by Public Agency for Service Provider.'},
  {:active => 1, :name => 'Leased by Service Provider',                   :code => 'LSP',  :description => 'Leased by Service Provider.'},
  {:active => 1, :name => 'Leased by Public Agency for Service Provider', :code => 'LPA',  :description => 'Leased by Public Agency for Service Provider.'},
  {:active => 1, :name => 'Other',                                        :code => 'OR',  :description => 'Other.'}
]

fta_vehicle_types = [
  # Rural Reporting Types
  {:active => 1, :name => 'Automobile',             :code => 'AO',  :description => 'Automobile.'},
  {:active => 1, :name => 'Bus',                    :code => 'BU',  :description => 'Bus.'},
  {:active => 1, :name => 'Cutaway',                :code => 'CU',  :description => 'Cutaway.'},
  {:active => 1, :name => 'Ferry Boat',             :code => 'FB',  :description => 'Ferryboat.'},
  {:active => 1, :name => 'Mini Van',               :code => 'MV',  :description => 'Minivan.'},
  {:active => 1, :name => 'Over-The-Road Bus',      :code => 'BR',  :description => 'Over-The-Road Bus.'},
  {:active => 1, :name => 'School Bus',             :code => 'SB',  :description => 'School Bus.'},
  {:active => 1, :name => 'Sports Utility Vehicle', :code => 'SV',  :description => 'Sports Utility Vehicle.'},
  {:active => 1, :name => 'Van',                    :code => 'VN',  :description => 'Van.'},
  {:active => 1, :name => 'Articulated Bus',        :code => 'AB',  :description => 'Articulated Bus.'},
  {:active => 1, :name => 'Double Decker Bus',      :code => 'DB',  :description => 'Double Decker Bus.'},
  {:active => 1, :name => 'Aerial Tramway',         :code => 'TR',  :description => 'Aerial Tramway.'},
  {:active => 1, :name => 'Other',                  :code => 'OR',  :description => 'Other.'},
  
  {:active => 1, :name => 'Unknown',                :code => 'XX', :description => 'Vehicle type not specified.'},
  
  # Urban Reporting Types
  {:active => 1, :name => 'Automated Guideway Vehicle',        :code => 'AG',  :description => 'Automated Guideway Vehicle.'},
  {:active => 1, :name => 'Cable Car',              :code => 'CC',  :description => 'Cable Car.'},
  {:active => 1, :name => 'Heavy Rail Passenger Car',  :code => 'HR',  :description => 'Heavy Rail Passenger Car.'},
  {:active => 1, :name => 'Inclined Plane Vehicle', :code => 'IP',  :description => 'Inclined Plane Vehicle.'},
  {:active => 1, :name => 'Light Rail Vehicle', :code => 'LR',  :description => 'Light Rail Vehicle.'},
  {:active => 1, :name => 'Monorail/Automated Guideway', :code => 'MO',  :description => 'Monorail/Automated Guideway.'},
  {:active => 1, :name => 'Commuter Rail Locomotive',                   :code => 'RL',  :description => 'Commuter Rail Locomotive.'},
  {:active => 1, :name => 'Commuter Rail Passenger Coach',              :code => 'RP',  :description => 'Commuter Rail Passenger Coach.'},
  {:active => 1, :name => 'Commuter Rail Self-Propelled Passenger Car', :code => 'RS',  :description => 'Commuter Rail Self-Propelled Passenger Car.'},
  {:active => 1, :name => 'Trolley Bus',            :code => 'TB',  :description => 'Trolley Bus.'},
  {:active => 1, :name => 'Taxicab Sedan',          :code => 'TS',  :description => 'Taxicab Sedan.'},
  {:active => 1, :name => 'Taxicab Van',            :code => 'TV',  :description => 'Taxicab Van.'},
  {:active => 1, :name => 'Taxicab Station Wagon',  :code => 'TW',  :description => 'Taxicab Station Wagon.'},
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

district_types = [
  {:active => 1, :name => 'State',        :description => 'State.'},
  {:active => 1, :name => 'District',     :description => 'Engineering District.'},
  {:active => 1, :name => 'MSA',          :description => 'Metropolitan Statistical Area.'},
  {:active => 1, :name => 'County',       :description => 'County.'},
  {:active => 1, :name => 'City',         :description => 'City.'},
  {:active => 1, :name => 'Borough',      :description => 'Borough.'},
  {:active => 1, :name => 'MPO/RPO',      :description => 'MPO or RPO planning area.'},
  {:active => 1, :name => 'Postal Code',  :description => 'ZIP Code or Postal Area.'}
]

file_content_types = [
  {:active => 1, :name => 'Status Updates',     :class_name => 'StatusUpdatesFileHandler',    :builder_name => "StatusUpdatesTemplateBuilder",  :description => 'Worksheet records condition, usage, and operational updates for exisiting inventory.'},
  {:active => 1, :name => 'Disposition Updates',  :class_name => 'DispositionUpdatesFileHandler', :builder_name => "DispositionUpdatesTemplateBuilder", :description => 'Worksheet contains final disposition updates for existing inventory.'}
]

service_provider_types = [
  {:active => 1, :name => 'Urban',            :code => 'URB',   :description => 'Operates in an urban area.'},
  {:active => 1, :name => 'Rural',            :code => 'RUR',   :description => 'Operates in a rural area.'},
  {:active => 1, :name => 'Shared Ride',      :code => 'SHR',   :description => 'Provides shared ride services.'},
  {:active => 1, :name => 'Intercity Bus',    :code => 'ICB',   :description => 'Provides intercity bus services.'},
  {:active => 1, :name => 'Intercity Rail',   :code => 'ICR',   :description => 'Provides intercity rail services.'}
]

vehicle_storage_method_types = [
  {:active => 1,  :name => 'Unknown',:code => 'X', :description => 'Vehicle storage method not supplied.'},
  {:active => 1,  :name => 'Indoors', :code => 'I', :description => 'Vehicle is always stored indoors.'},
  {:active => 1,  :name => 'Outdoors', :code => 'O', :description => 'Vehicle is always stored outdoors.'},
  {:active => 1,  :name => 'Indoor/Outdoor', :code => 'B', :description => 'Vehicle is stored both indoors and outdoors.'}
]

maintenance_provider_types = [
  {:active => 1,  :name => 'Unknown',         :code => 'XX', :description => 'Maintenance provider not supplied.'},
  {:active => 1,  :name => 'Self Maintained', :code => 'SM', :description => 'Self Maintained.'},
  {:active => 1,  :name => 'County',          :code => 'CO', :description => 'County.'},
  {:active => 1,  :name => 'Public Agency',   :code => 'PA', :description => 'Public Agency.'},
  {:active => 1,  :name => 'Private Entity',  :code => 'PE', :description => 'Private Entity.'}
]

funding_source_types = [
  {:active => 1, :name => 'Federal',  :description => 'Federal Funding Source'},
  {:active => 1, :name => 'State',    :description => 'State Funding Source'},
  {:active => 1, :name => 'Other',    :description => 'Other Funding Source'}
]

governing_body_types = [
  {:active => 1, :name => 'Corporate Board of Directors',   :description => 'Corporate Board of Directors'},
  {:active => 1, :name => 'Authority Board',   :description => 'Board of Directors'},
  {:active => 1, :name => 'County',   :description => 'County'},
  {:active => 1, :name => 'City',   :description => 'City'},
  {:active => 1, :name => 'Other',                :description => 'Other Governing Body'}
]

replace_tables = %w{ fuel_types vehicle_features vehicle_usage_codes fta_mode_types fta_agency_types fta_service_area_types
  fta_service_types fta_funding_types fta_ownership_types fta_vehicle_types facility_capacity_types
  facility_features district_types maintenance_provider_types funding_source_types
  file_content_types service_provider_types
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
  {:active => 1, :name => 'Update the operations metrics',      :display_icon_name => "fa fa-calculator",        :description => 'Operations Update',:class_name => 'OperationsUpdateEvent',     :job_name => 'AssetOperationsUpdateJob'},
  {:active => 1, :name => 'Update the use metrics',           :display_icon_name => "fa fa-line-chart",      :description => 'Usage Update',     :class_name => 'UsageUpdateEvent',          :job_name => 'AssetUsageUpdateJob'},
  {:active => 1, :name => 'Update the storage method',       :display_icon_name => "fa fa-star-half-o",       :description => 'Storage Method',       :class_name => 'StorageMethodUpdateEvent',      :job_name => 'AssetStorageMethodUpdateJob'},
  {:active => 1, :name => 'Update the usage codes',       :display_icon_name => "fa fa-star-half-o",       :description => 'Usage Codes',       :class_name => 'UsageCodesUpdateEvent',      :job_name => 'AssetUsageCodesUpdateJob'}
]

contact_types = [
{:name => "Director of Transit Unit", :code => "DTU"},
{:name =>"NTD Reporting Contact", :code => "NTD"}
]

condition_estimation_types = [
  {:active => 1, :name => 'TERM',           :class_name => 'TermEstimationCalculator',          :description => 'Asset condition is estimated using FTA TERM approximations.'}
]
service_life_calculation_types = [
  {:active => 1, :name => 'Age and Mileage',   :class_name => 'ServiceLifeAgeAndMileage',   :description => 'Calculate the replacement year based on the age of the asset or mileage whichever minimizes asset life.'}
]

merge_tables = %w{ asset_event_types contact_types condition_estimation_types service_life_calculation_types }

merge_tables.each do |table_name|
  puts "  Merging #{table_name}"
  data = eval(table_name)
  klass = table_name.classify.constantize
  data.each do |row|
    x = klass.new(row)
    x.save!
  end
end



puts "======= Processing TransAM Transit Reports  ======="

reports = [
  {:active => 1, :belongs_to => 'report_type', :type => "Inventory Report",
    :name => 'Useful Life Consumed Report',
    :class_name => "ServiceLifeConsumedReport",
    :view_name => "generic_chart",
    :show_in_nav => 1,
    :show_in_dashboard => 0,
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
