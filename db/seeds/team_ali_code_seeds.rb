#encoding: utf-8

# determine if we are using mysql or sqlite
is_mysql = (ActiveRecord::Base.configurations[Rails.env]['adapter'].include? 'mysql2')
is_sqlite =  (ActiveRecord::Base.configurations[Rails.env]['adapter'] == 'sqlite3')

table_name = 'team_ali_codes'
puts "  Processing #{table_name}"
if is_mysql
  ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table_name};")
elsif is_sqlite
  ActiveRecord::Base.connection.execute("DELETE FROM #{table_name};")
else
  ActiveRecord::Base.connection.execute("TRUNCATE #{table_name} RESTART IDENTITY;")
end

# Start to build the Scope/ALI tree

# Set the root nodes, these are top level categories
TeamAliCode.create!(:name => 'Capital',    :code => '1X.XX.XX')

level_1 = [
  {:name => 'Bus',        :code => '11.XX.XX', :parent_code => '1X.XX.XX'},
  {:name => 'Rail',       :code => '12.XX.XX', :parent_code => '1X.XX.XX'},
  {:name => 'New Start',  :code => '14.XX.XX', :parent_code => '1X.XX.XX'}
]
level_1.each do |h|
  node = TeamAliCode.create!(h.except(:parent_code))
  parent = TeamAliCode.find_by_code(h[:parent_code])
  node.move_to_child_of(parent)
end

# Level 2 for Bus and Fixed Guideways
level_2 = [
  {:name => 'Revenue Rolling Stock',            :cat_code => 'XX.1X.XX'},
  {:name => 'Transitway Lines',                 :cat_code => 'XX.2X.XX'},
  {:name => 'Station Stops/Terminals',          :cat_code => 'XX.3X.XX'},
  {:name => 'Support Facilities and Equipment', :cat_code => 'XX.4X.XX'},
  {:name => 'Electrification Power Dist.',      :cat_code => 'XX.5X.XX'},
  {:name => 'Signal & Communication',           :cat_code => 'XX.6X.XX'},
  {:name => 'Other Capital Program Items.',     :cat_code => 'XX.7X.XX'},
  {:name => 'State or Program Administration',  :cat_code => 'XX.80.00'},
  {:name => 'Transit Enhancements',             :cat_code => 'XX.9X.XX'}
]
# Build the second level for each of the bus and fixed guideway nodes
%w{11.XX.XX 12.XX.XX}.each do |parent_code|
  parent = TeamAliCode.find_by_code(parent_code)
  level_2.each do |h|
    pc = parent_code.split('.')[0]
    tc = h[:cat_code].split('.')[1]
    ac = h[:cat_code].split('.')[2]
    code = "#{pc}.#{tc}.#{ac}"
    node = TeamAliCode.create!(:name => h[:name], :code => code)
    node.move_to_child_of(parent)
  end
end

# Third level for rolling stock only
level_3_rrs = [
  {:name => 'Engineering & Design',     :cat_code => 'XX.11.XX'},
  {:name => 'Purchase - Replacement',   :cat_code => 'XX.12.XX'},
  {:name => 'Purchase - Expansion',     :cat_code => 'XX.13.XX'},
  {:name => 'Rehabilitation/Rebuild',   :cat_code => 'XX.14.XX'},
  {:name => 'Mid Life Rebuild (Rail)',  :cat_code => 'XX.15.XX'},
  {:name => 'Lease - Replacement',      :cat_code => 'XX.16.XX'},
  {:name => 'Lease - Expansion',        :cat_code => 'XX.18.XX'},
  {:name => 'Vehicle Overhaul',         :cat_code => 'XX.17.00'}
]
# Build the third level for each of the bus and fixed guideway nodes
%w{11.1X.XX 12.1X.XX}.each do |parent_code|
  parent = TeamAliCode.find_by_code(parent_code)
  level_3_rrs.each do |h|
    pc = parent_code.split('.')[0]
    tc = h[:cat_code].split('.')[1]
    ac = h[:cat_code].split('.')[2]
    code = "#{pc}.#{tc}.#{ac}"
    node = TeamAliCode.create!(:name => h[:name], :code => code)
    node.move_to_child_of(parent)
  end
end

# Third level for other
level_3_oth = [
  {:name => 'Engineering & Design',     :cat_code => 'XX.X1.XX'},
  {:name => 'Acquisition',              :cat_code => 'XX.X2.XX'},
  {:name => 'Construction',             :cat_code => 'XX.X3.XX'},
  {:name => 'Rehab/Renovation',         :cat_code => 'XX.X4.XX'},
  {:name => 'Lease',                    :cat_code => 'XX.X6.XX'}
]

# Build the third level for each of the bus and fixed guideway nodes
%w{11.XX.XX 12.XX.XX}.each do |top_code|
  %w{XX.2X.XX XX.3X.XX XX.4X.XX XX.5X.XX XX.6X.XX}.each do |type_code|
    pc = top_code.split('.')[0]
    tc = type_code.split('.')[1]
    ac = type_code.split('.')[2]
    parent_code = "#{pc}.#{tc}.#{ac}"
    parent = TeamAliCode.find_by_code(parent_code)

    level_3_oth.each do |h|
      tc1 = "#{tc.first}#{h[:cat_code].split('.')[1].last}"
      ac1 = h[:cat_code].split('.')[2]
      code = "#{pc}.#{tc1}.#{ac1}"
      node = TeamAliCode.create!(:name => h[:name], :code => code)
      node.move_to_child_of(parent)
    end
  end
end

# Third level for enhancements
level_3_enh = [
  {:name => 'Engineering & Design',     :cat_code => 'XX.X1.XX'},
  {:name => 'Acquisition',              :cat_code => 'XX.X2.XX'},
  {:name => 'Construction',             :cat_code => 'XX.X3.XX'},
  {:name => 'Rehab/Renovation',         :cat_code => 'XX.X4.XX'},
  {:name => 'Lease',                    :cat_code => 'XX.X5.XX'}
]
# Build the third level for each of the bus and fixed guideway nodes for enhancements
%w{11.XX.XX 12.XX.XX}.each do |top_code|
  %w{XX.9X.XX}.each do |type_code|
    pc = top_code.split('.')[0]
    tc = type_code.split('.')[1]
    ac = type_code.split('.')[2]
    parent_code = "#{pc}.#{tc}.#{ac}"
    parent = TeamAliCode.find_by_code(parent_code)

    level_3_enh.each do |h|
      tc1 = "#{tc.first}#{h[:cat_code].split('.')[1].last}"
      ac1 = h[:cat_code].split('.')[2]
      code = "#{pc}.#{tc1}.#{ac1}"
      node = TeamAliCode.create!(:name => h[:name], :code => code)
      node.move_to_child_of(parent)
    end
  end
end

# Add the asset subtypes for the revenue rolling stock
level_4_rrs = [
  {:name => 'Bus STD 40 Ft',          :cat_code => 'XX.XX.01'},
  {:name => 'Bus STD 35 Ft',          :cat_code => 'XX.XX.02'},
  {:name => 'Bus 30 Ft',              :cat_code => 'XX.XX.03'},
  {:name => 'Bus < 30 Ft',            :cat_code => 'XX.XX.04'},
  {:name => 'Bus School',             :cat_code => 'XX.XX.05'},
  {:name => 'Bus Articulated',        :cat_code => 'XX.XX.06'},
  {:name => 'Bus Commuter/Suburban',  :cat_code => 'XX.XX.07'},
  {:name => 'Bus Intercity',          :cat_code => 'XX.XX.08'},
  {:name => 'Bus Troley STD',         :cat_code => 'XX.XX.09'},
  {:name => 'Bus Trolley Artic.',     :cat_code => 'XX.XX.10'},
  {:name => 'Bus Double Deck',        :cat_code => 'XX.XX.11'},
  {:name => 'Bus Used',               :cat_code => 'XX.XX.12'},
  {:name => 'Bus School Used',        :cat_code => 'XX.XX.13'},
  {:name => 'Bus Dual Mode',          :cat_code => 'XX.XX.14'},
  {:name => 'Van',                    :cat_code => 'XX.XX.15'},
  {:name => 'Sedan/Station Wagon',    :cat_code => 'XX.XX.16'},
  {:name => 'Light Rail Car',         :cat_code => 'XX.XX.20'},
  {:name => 'Heavy Rail Car',         :cat_code => 'XX.XX.21'},
  {:name => 'Commuter Rail Self Propelled - Elec',  :cat_code => 'XX.XX.22'},
  {:name => 'Commuter Rail Car Trailer',            :cat_code => 'XX.XX.23'},
  {:name => 'Commuter Locomotive Disel',            :cat_code => 'XX.XX.24'},
  {:name => 'Commuter Locomotive Electric',         :cat_code => 'XX.XX.25'},
  {:name => 'Commuter Rail Cars Used',              :cat_code => 'XX.XX.26'},
  {:name => 'Commuter Locomotive Used',             :cat_code => 'XX.XX.27'},
  {:name => 'Commuter Rail Self Prop - Diesel',     :cat_code => 'XX.XX.28'},
  {:name => 'Cable Car',              :cat_code => 'XX.XX.30'},
  {:name => 'People Mover',           :cat_code => 'XX.XX.31'},
  {:name => 'Car, Incline Railway',   :cat_code => 'XX.XX.32'},
  {:name => 'Ferry Boats',            :cat_code => 'XX.XX.33'},
  {:name => 'Transferred Vehicle',    :cat_code => 'XX.XX.39'},
  {:name => 'Spare Parts/ Assoc Capital Main. Items', :cat_code => 'XX.XX.40'}
]

# Build the fourth level for the revenue rolling stock
%w{11.XX.XX 12.XX.XX}.each do |top_code|
  %w{XX.11.XX XX.12.XX XX.13.XX XX.14.XX XX.15.XX XX.16.XX XX.18.XX}.each do |type_code|
    pc = top_code.split('.')[0]
    tc = type_code.split('.')[1]
    ac = type_code.split('.')[2]
    parent_code = "#{pc}.#{tc}.#{ac}"
    parent = TeamAliCode.find_by_code(parent_code)

    level_4_rrs.each do |h|
      ac1 = h[:cat_code].split('.')[2]
      code = "#{pc}.#{tc}.#{ac1}"
      node = TeamAliCode.create!(:name => h[:name], :code => code)
      node.move_to_child_of(parent)
    end
  end
end

# Build the fourth level for the transit way lines
level_4_twl = [
  {:name => 'Busway',                     :cat_code => 'XX.XX.01'},
  {:name => 'Transit Mall',               :cat_code => 'XX.XX.02'},
  {:name => 'Line Equipment/Struc Misc',  :cat_code => 'XX.XX.03'},
  {:name => 'Tunnels',                    :cat_code => 'XX.XX.04'},
  {:name => 'Bridges',                    :cat_code => 'XX.XX.05'},
  {:name => 'Elevated Structures',        :cat_code => 'XX.XX.06'},
  {:name => 'People Mover',               :cat_code => 'XX.XX.07'},
  {:name => 'Miscellaneous Equipment',    :cat_code => 'XX.XX.20'}
]
%w{11.XX.XX 12.XX.XX}.each do |top_code|
  %w{XX.21.XX XX.22.XX XX.23.XX XX.24.XX XX.26.XX}.each do |type_code|
    pc = top_code.split('.')[0]
    tc = type_code.split('.')[1]
    ac = type_code.split('.')[2]
    parent_code = "#{pc}.#{tc}.#{ac}"
    parent = TeamAliCode.find_by_code(parent_code)

    level_4_twl.each do |h|
      ac1 = h[:cat_code].split('.')[2]
      code = "#{pc}.#{tc}.#{ac1}"
      node = TeamAliCode.create!(:name => h[:name], :code => code)
      node.move_to_child_of(parent)
    end
  end
end

# Build the fourth level for the stations/stops/terminals
level_4_sst = [
  {:name => 'Terminal, Bus',                  :cat_code => 'XX.XX.01'},
  {:name => 'Station',                        :cat_code => 'XX.XX.02'},
  {:name => 'Terminal, Intermodal',           :cat_code => 'XX.XX.03'},
  {:name => 'Park and Ride Lot',              :cat_code => 'XX.XX.04'},
  {:name => 'Terminal, Ferry',                :cat_code => 'XX.XX.05'},
  {:name => 'Fare Collection Equipment',      :cat_code => 'XX.XX.06'},
  {:name => 'Surveillance/Security Systems',  :cat_code => 'XX.XX.07'},
  {:name => 'Furniture and Graphics',         :cat_code => 'XX.XX.08'},
  {:name => 'Route Signing',                  :cat_code => 'XX.XX.09'},
  {:name => 'Passenger Shelters',             :cat_code => 'XX.XX.10'},
  {:name => 'Miscellaneous',                  :cat_code => 'XX.XX.20'}
]
%w{11.XX.XX 12.XX.XX}.each do |top_code|
  %w{XX.31.XX XX.32.XX XX.33.XX XX.34.XX XX.36.XX}.each do |type_code|
    pc = top_code.split('.')[0]
    tc = type_code.split('.')[1]
    ac = type_code.split('.')[2]
    parent_code = "#{pc}.#{tc}.#{ac}"
    parent = TeamAliCode.find_by_code(parent_code)

    level_4_sst.each do |h|
      ac1 = h[:cat_code].split('.')[2]
      code = "#{pc}.#{tc}.#{ac1}"
      node = TeamAliCode.create!(:name => h[:name], :code => code)
      node.move_to_child_of(parent)
    end
  end
end

# Build the fourth level for the support facilities and equipment
level_4_sfe = [
  {:name => 'Admin Building',           :cat_code => 'XX.XX.01'},
  {:name => 'Maintenance Facility',     :cat_code => 'XX.XX.02'},
  {:name => 'Admin/Maint Facility',     :cat_code => 'XX.XX.03'},
  {:name => 'Storage Facility',         :cat_code => 'XX.XX.04'},
  {:name => 'Yards and Shops',          :cat_code => 'XX.XX.05'},
  {:name => 'Shop Equipment',           :cat_code => 'XX.XX.06'},
  {:name => 'ADP Hardware',             :cat_code => 'XX.XX.07'},
  {:name => 'ADP Software',             :cat_code => 'XX.XX.08'},
  {:name => 'Surveillance/Security',    :cat_code => 'XX.XX.09'},
  {:name => 'Fare Collection (mobile)', :cat_code => 'XX.XX.10'},
  {:name => 'Support Vehicles',         :cat_code => 'XX.XX.11'},
  {:name => 'Work Trains',              :cat_code => 'XX.XX.12'},
  {:name => 'Miscellaneous Equipment',  :cat_code => 'XX.XX.20'},
  {:name => 'Excl Bicycles Vehicle',    :cat_code => 'XX.XX.40'},
  {:name => 'Excl Bicycles Equipment',  :cat_code => 'XX.XX.41'},
  {:name => 'Excl Bicycles Facility',   :cat_code => 'XX.XX.42'},
  {:name => 'ADA Equipment',            :cat_code => 'XX.XX.43'},
  {:name => 'CAA Equipment',            :cat_code => 'XX.XX.44'}
]
%w{11.XX.XX 12.XX.XX}.each do |top_code|
  %w{XX.41.XX XX.42.XX XX.43.XX XX.44.XX XX.46.XX}.each do |type_code|
    pc = top_code.split('.')[0]
    tc = type_code.split('.')[1]
    ac = type_code.split('.')[2]
    parent_code = "#{pc}.#{tc}.#{ac}"
    parent = TeamAliCode.find_by_code(parent_code)

    level_4_sfe.each do |h|
      ac1 = h[:cat_code].split('.')[2]
      code = "#{pc}.#{tc}.#{ac1}"
      node = TeamAliCode.create!(:name => h[:name], :code => code)
      node.move_to_child_of(parent)
    end
  end
end

# Build the fourth level for the electrification power distribution
level_4_epd = [
  {:name => 'Traction Power',                 :cat_code => 'XX.XX.01'},
  {:name => 'AC Power Lighting',              :cat_code => 'XX.XX.02'},
  {:name => 'Power Distributioun Substation', :cat_code => 'XX.XX.03'},
  {:name => 'Vehicle Locator System',         :cat_code => 'XX.XX.04'},
  {:name => 'Miscellaneous',                  :cat_code => 'XX.XX.20'}
]
%w{11.XX.XX 12.XX.XX}.each do |top_code|
  %w{XX.51.XX XX.52.XX XX.53.XX XX.54.XX XX.56.XX}.each do |type_code|
    pc = top_code.split('.')[0]
    tc = type_code.split('.')[1]
    ac = type_code.split('.')[2]
    parent_code = "#{pc}.#{tc}.#{ac}"
    parent = TeamAliCode.find_by_code(parent_code)

    level_4_epd.each do |h|
      ac1 = h[:cat_code].split('.')[2]
      code = "#{pc}.#{tc}.#{ac1}"
      node = TeamAliCode.create!(:name => h[:name], :code => code)
      node.move_to_child_of(parent)
    end
  end
end

# Build the fourth level for signal and communications
level_4_sac = [
  {:name => 'Train Control/Signal System',  :cat_code => 'XX.XX.01'},
  {:name => 'Communications Systems',       :cat_code => 'XX.XX.02'},
  {:name => 'Radios',                       :cat_code => 'XX.XX.03'},
  {:name => 'Miscellaneous Equipment',      :cat_code => 'XX.XX.20'}
]
%w{11.XX.XX 12.XX.XX}.each do |top_code|
  %w{XX.61.XX XX.62.XX XX.63.XX XX.64.XX XX.66.XX}.each do |type_code|
    pc = top_code.split('.')[0]
    tc = type_code.split('.')[1]
    ac = type_code.split('.')[2]
    parent_code = "#{pc}.#{tc}.#{ac}"
    parent = TeamAliCode.find_by_code(parent_code)

    level_4_sac.each do |h|
      ac1 = h[:cat_code].split('.')[2]
      code = "#{pc}.#{tc}.#{ac1}"
      node = TeamAliCode.create!(:name => h[:name], :code => code)
      node.move_to_child_of(parent)
    end
  end
end

# Build the fourth level for transit enhancements
level_4_enh = [
  {:name => 'Historic Mass Transp. Bldgs., including Operations', :cat_code => 'XX.XX.01'},
  {:name => 'Bus Shelters',                                       :cat_code => 'XX.XX.02'},
  {:name => 'Landscaping/Scenic Beautification',                  :cat_code => 'XX.XX.03'},
  {:name => 'Public Art',                                         :cat_code => 'XX.XX.04'},
  {:name => 'Pedestrian Access/Walkways',                         :cat_code => 'XX.XX.05'},
  {:name => 'Bicycle Access, Facilities, & Equipment on Busses',  :cat_code => 'XX.XX.06'},
  {:name => 'Transit Connections to Parks',                       :cat_code => 'XX.XX.07'},
  {:name => 'Signage',                                            :cat_code => 'XX.XX.08'},
  {:name => 'Enhanced ADA Access',                                :cat_code => 'XX.XX.09'},
]
%w{11.XX.XX 12.XX.XX}.each do |top_code|
  %w{XX.91.XX XX.92.XX XX.93.XX XX.94.XX XX.95.XX}.each do |type_code|
    pc = top_code.split('.')[0]
    tc = type_code.split('.')[1]
    ac = type_code.split('.')[2]
    parent_code = "#{pc}.#{tc}.#{ac}"
    parent = TeamAliCode.find_by_code(parent_code)

    level_4_enh.each do |h|
      ac1 = h[:cat_code].split('.')[2]
      code = "#{pc}.#{tc}.#{ac1}"
      node = TeamAliCode.create!(:name => h[:name], :code => code)
      node.move_to_child_of(parent)
    end
  end
end


# possibly integrate into tree above but these were intentionally left out by Julian initially abut later requested so adding after the fact
new_codes = [
    {code: '11.71.XX', name: '3rd Party Contracts', parent_code: '11.7X.XX'},
    {code: '11.71.01', name: 'Preliminary Engineering', parent_code: '11.71.XX'},
    {code: '11.71.02', name: 'Final Design Services', parent_code: '11.71.XX'},
    {code: '11.71.03', name: 'Project Management', parent_code: '11.71.XX'},
    {code: '11.71.04', name: 'Construction Management', parent_code: '11.71.XX'},
    {code: '11.71.05', name: 'Insurance', parent_code: '11.71.XX'},
    {code: '11.71.06', name: 'Legal', parent_code: '11.71.XX'},
    {code: '11.71.07', name: 'Audit', parent_code: '11.71.XX'},
    {code: '11.71.08', name: 'Construction (Force Account)', parent_code: '11.71.XX'},
    {code: '11.71.09', name: 'Rolling Stock Rehab (FA)', parent_code: '11.71.XX'},
    {code: '11.71.10', name: 'Inspection (FA)', parent_code: '11.71.XX'},
    {code: '11.71.11', name: 'Other', parent_code: '11.71.XX'},
    {code: '11.71.12', name: 'Capital Cost of Contracting', parent_code: '11.71.XX'},
    {code: '11.71.13', name: 'Contracted Service (5310 only)', parent_code: '11.71.XX'},
    {code: '11.73.00', name: 'Contingencies/Program Reserve', parent_code: '11.7X.XX'},
    {code: '11.74.00', name: 'Public Buyout', parent_code: '11.7X.XX'},
    {code: '11.77.00', name: 'Project Income', parent_code: '11.7X.XX'},
    {code: '11.78.00', name: 'Capital Project Income', parent_code: '11.7X.XX'},
    {code: '11.79.00', name: 'Project Administration', parent_code: '11.7X.XX'},
    {code: '11.7A.00', name: 'Preventive Maintenance', parent_code: '11.7X.XX'},
    {code: '11.7B.00', name: 'SIB Capitalization', parent_code: '11.7X.XX'},
    {code: '11.7C.00', name: 'Non Fixed Route ADA Paratransit', parent_code: '11.7X.XX'},
    {code: '11.7E.00', name: 'Community Service Facilities', parent_code: '11.7X.XX'},
    {code: '11.7F.00', name: 'TDM Activities - CMAQ only', parent_code: '11.7X.XX'},
    {code: '11.7L.00', name: 'Mobility Management (5302(a)(1)(L)', parent_code: '11.7X.XX'},
    {code: '11.7M.00', name: 'Debt Service Reserve (5302(a)(1)(K)', parent_code: '11.7X.XX'},
    {code: '11.7P.00', name: 'Transit Asset Management (5337, 5307, 5311)', parent_code: '11.7X.XX'},
    {code:'11.72.XX',name:'Force Account',parent_code:'11.7X.XX'},
    {code:'11.72.01',name:'Preliminary Engineering',parent_code:'11.72.XX'},
    {code:'11.72.02',name:'Final Design Services',parent_code:'11.72.XX'},
    {code:'11.72.03',name:'Project Management',parent_code:'11.72.XX'},
    {code:'11.72.04',name:'Construction Management',parent_code:'11.72.XX'},
    {code:'11.72.05',name:'Insurance',parent_code:'11.72.XX'},
    {code:'11.72.06',name:'Legal',parent_code:'11.72.XX'},
    {code:'11.72.07',name:'Audit',parent_code:'11.72.XX'},
    {code:'11.72.08',name:'Construction (Force Account)',parent_code:'11.72.XX'},
    {code:'11.72.09',name:'Rolling Stock Rehab (FA)',parent_code:'11.72.XX'},
    {code:'11.72.10',name:'Inspection (FA)',parent_code:'11.72.XX'},
    {code:'11.72.11',name:'Other',parent_code:'11.72.XX'},
    {code:'11.72.12',name:'Capital Cost of Contracting',parent_code:'11.72.XX'},
    {code:'11.72.13',name:'Contracted Service (5310 only)',parent_code:'11.72.XX'},
    {code:'11.75.XX',name:'Real Estate (R/W)',parent_code:'11.7X.XX'},
    {code:'11.75.91',name:'Acquisition',parent_code:'11.75.XX'},
    {code:'11.75.92',name:'Relocation (Actual)',parent_code:'11.75.XX'},
    {code:'11.75.93',name:'Demolition',parent_code:'11.75.XX'},
    {code:'11.75.94',name:'Appraisal',parent_code:'11.75.XX'},
    {code:'11.75.95',name:'Utility Relocation',parent_code:'11.75.XX'},
    {code:'11.75.96',name:'Construction',parent_code:'11.75.XX'},
    {code:'11.75.97',name:'Rehabilitation',parent_code:'11.75.XX'},
    {code:'11.75.98',name:'Lease',parent_code:'11.75.XX'},
    {code:'11.76.XX',name:'Real Estate (Other)',parent_code:'11.7X.XX'},
    {code:'11.76.91',name:'Acquisition',parent_code:'11.76.XX'},
    {code:'11.76.92',name:'Relocation (Actual)',parent_code:'11.76.XX'},
    {code:'11.76.93',name:'Demolition',parent_code:'11.76.XX'},
    {code:'11.76.94',name:'Appraisal',parent_code:'11.76.XX'},
    {code:'11.76.95',name:'Utility Relocation',parent_code:'11.76.XX'},
    {code:'11.76.96',name:'Construction',parent_code:'11.76.XX'},
    {code:'11.76.97',name:'Rehabilitation',parent_code:'11.76.XX'},
    {code:'11.76.98',name:'Lease',parent_code:'11.76.XX'},
    {code:'11.7D.XX',name:'Training - Capital Bus',parent_code:'11.7X.XX'},
    {code:'11.7D.01',name:'OVER THE ROAD BUS PRGM.',parent_code:'11.7D.XX'},
    {code:'11.7D.02',name:'EMPLOYEE EDUCATION/TRAINING',parent_code:'11.7D.XX'},
    {code:'11.7K.XX',name:'Crime Prevent/Security - Capital Bus',parent_code:'11.7X.XX'},
    {code:'11.7K.01',name:'SECURITY AND EMERGENCY RESPONSE PLANS',parent_code:'11.7K.XX'},
    {code:'11.7K.02',name:'BIOLOGICAL/CHEMICAL AGENT DETECTION',parent_code:'11.7K.XX'},
    {code:'11.7K.03',name:'EMERGENCY RESPONSE DRILLS',parent_code:'11.7K.XX'},
    {code:'11.7K.04',name:'SECURITY TRAINING',parent_code:'11.7K.XX'},
    {code:'11.7N.XX',name:'Special Fuel Provision - Capital Bus',parent_code:'11.7X.XX'},
    {code:'11.7N.01',name:'FUEL FOR VEHICLE OPERATIONS',parent_code:'11.7N.XX'},
    {code:'11.7N.02',name:'UTILITY COSTS FOR ELECTRICAL VEHICLES',parent_code:'11.7N.XX'},
    {code:'12.7X.XX',name:'Other Capital Program Items.',parent_code:'12.XX.XX'},
    {code:'12.71.XX',name:'3rd Party Contracts',parent_code:'12.7X.XX'},
    {code:'12.71.01',name:'Preliminary Engineering',parent_code:'12.71.XX'},
    {code:'12.71.02',name:'Final Design Services',parent_code:'12.71.XX'},
    {code:'12.71.03',name:'Project Management',parent_code:'12.71.XX'},
    {code:'12.71.04',name:'Construction Management',parent_code:'12.71.XX'},
    {code:'12.71.05',name:'Insurance',parent_code:'12.71.XX'},
    {code:'12.71.06',name:'Legal',parent_code:'12.71.XX'},
    {code:'12.71.07',name:'Audit',parent_code:'12.71.XX'},
    {code:'12.71.08',name:'Construction (Force Account)',parent_code:'12.71.XX'},
    {code:'12.71.09',name:'Rolling Stock Rehab (FA)',parent_code:'12.71.XX'},
    {code:'12.71.10',name:'Inspection (FA)',parent_code:'12.71.XX'},
    {code:'12.71.11',name:'Other',parent_code:'12.71.XX'},
    {code:'12.71.12',name:'Capital Cost of Contracting',parent_code:'12.71.XX'},
    {code:'12.71.13',name:'Contracted Service (5310 only)',parent_code:'12.71.XX'},
    {code:'12.73.00',name:'Contingencies/Program Reserve',parent_code:'12.7X.XX'},
    {code:'12.74.00',name:'Public Buyout',parent_code:'12.7X.XX'},
    {code:'12.77.00',name:'Project Income',parent_code:'12.7X.XX'},
    {code:'12.78.00',name:'Capital Project Income',parent_code:'12.7X.XX'},
    {code:'12.79.00',name:'Project Administration',parent_code:'12.7X.XX'},
    {code:'12.7A.00',name:'Preventive Maintenance',parent_code:'12.7X.XX'},
    {code:'12.7B.00',name:'SIB Capitalization',parent_code:'12.7X.XX'},
    {code:'12.7C.00',name:'Non Fixed Route ADA Paratransit',parent_code:'12.7X.XX'},
    {code:'12.7E.00',name:'Community Service Facilities',parent_code:'12.7X.XX'},
    {code:'12.7F.00',name:'TDM Activities - CMAQ only',parent_code:'12.7X.XX'},
    {code:'12.7L.00',name:'Mobility Management (5302(a)(1)(L)',parent_code:'12.7X.XX'},
    {code:'12.7M.00',name:'Debt Service Reserve (5302(a)(1)(K)',parent_code:'12.7X.XX'},
    {code:'12.7P.00',name:'Transit Asset Management (5337, 5307, 5311)',parent_code:'12.7X.XX'},
    {code:'12.72.XX',name:'Force Account',parent_code:'12.7X.XX'},
    {code:'12.72.01',name:'Preliminary Engineering',parent_code:'12.72.XX'},
    {code:'12.72.02',name:'Final Design Services',parent_code:'12.72.XX'},
    {code:'12.72.03',name:'Project Management',parent_code:'12.72.XX'},
    {code:'12.72.04',name:'Construction Management',parent_code:'12.72.XX'},
    {code:'12.72.05',name:'Insurance',parent_code:'12.72.XX'},
    {code:'12.72.06',name:'Legal',parent_code:'12.72.XX'},
    {code:'12.72.07',name:'Audit',parent_code:'12.72.XX'},
    {code:'12.72.08',name:'Construction (Force Account)',parent_code:'12.72.XX'},
    {code:'12.72.09',name:'Rolling Stock Rehab (FA)',parent_code:'12.72.XX'},
    {code:'12.72.10',name:'Inspection (FA)',parent_code:'12.72.XX'},
    {code:'12.72.11',name:'Other',parent_code:'12.72.XX'},
    {code:'12.72.12',name:'Capital Cost of Contracting',parent_code:'12.72.XX'},
    {code:'12.72.13',name:'Contracted Service (5310 only)',parent_code:'12.72.XX'},
    {code:'12.75.XX',name:'Real Estate (R/W)',parent_code:'12.7X.XX'},
    {code:'12.75.91',name:'Acquisition',parent_code:'12.75.XX'},
    {code:'12.75.92',name:'Relocation (Actual)',parent_code:'12.75.XX'},
    {code:'12.75.93',name:'Demolition',parent_code:'12.75.XX'},
    {code:'12.75.94',name:'Appraisal',parent_code:'12.75.XX'},
    {code:'12.75.95',name:'Utility Relocation',parent_code:'12.75.XX'},
    {code:'12.75.96',name:'Construction',parent_code:'12.75.XX'},
    {code:'12.75.97',name:'Rehabilitation',parent_code:'12.75.XX'},
    {code:'12.75.98',name:'Lease',parent_code:'12.75.XX'},
    {code:'12.76.XX',name:'Real Estate (Other)',parent_code:'12.7X.XX'},
    {code:'12.76.91',name:'Acquisition',parent_code:'12.76.XX'},
    {code:'12.76.92',name:'Relocation (Actual)',parent_code:'12.76.XX'},
    {code:'12.76.93',name:'Demolition',parent_code:'12.76.XX'},
    {code:'12.76.94',name:'Appraisal',parent_code:'12.76.XX'},
    {code:'12.76.95',name:'Utility Relocation',parent_code:'12.76.XX'},
    {code:'12.76.96',name:'Construction',parent_code:'12.76.XX'},
    {code:'12.76.97',name:'Rehabilitation',parent_code:'12.76.XX'},
    {code:'12.76.98',name:'Lease',parent_code:'12.76.XX'},
    {code:'12.7D.XX',name:'Training - Capital Bus',parent_code:'12.7X.XX'},
    {code:'12.7D.01',name:'OVER THE ROAD BUS PRGM.',parent_code:'12.7D.XX'},
    {code:'12.7D.02',name:'EMPLOYEE EDUCATION/TRAINING',parent_code:'12.7D.XX'},
    {code:'12.7K.XX',name:'Crime Prevent/Security - Capital Bus',parent_code:'12.7X.XX'},
    {code:'12.7K.01',name:'SECURITY AND EMERGENCY RESPONSE PLANS',parent_code:'12.7K.XX'},
    {code:'12.7K.02',name:'BIOLOGICAL/CHEMICAL AGENT DETECTION',parent_code:'12.7K.XX'},
    {code:'12.7K.03',name:'EMERGENCY RESPONSE DRILLS',parent_code:'12.7K.XX'},
    {code:'12.7K.04',name:'SECURITY TRAINING',parent_code:'12.7K.XX'},
    {code:'12.7N.XX',name:'Special Fuel Provision - Capital Bus',parent_code:'12.7X.XX'},
    {code:'12.7N.01',name:'FUEL FOR VEHICLE OPERATIONS',parent_code:'12.7N.XX'},
    {code:'12.7N.02',name:'UTILITY COSTS FOR ELECTRICAL VEHICLES',parent_code:'12.7N.XX'},
]

new_codes.each do |team_ali_code|
  if TeamAliCode.find_by(code: team_ali_code[:code]).nil?
    parent = TeamAliCode.find_by(code: team_ali_code[:parent_code])
    if parent.present?
      node = TeamAliCode.create!(:name => team_ali_code[:name], :code => team_ali_code[:code])
      node.move_to_child_of(parent)
    else
      puts "Can't create #{team_ali_code[:code]} because no parent"
    end
  end
end





