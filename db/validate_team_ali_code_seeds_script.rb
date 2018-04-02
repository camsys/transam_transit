# Validates that engine team ali code seed data has loaded as expected
# Added to the dynamically generated tmp/validate_seeds_data.rb file
# Via the transam_{engine_name}:validate_engine_seeds rake task
# Which should only be called from an app-level validate_engine_seeds rake task

# NOTE: We don't get data dynamically from db/team_ali_code_seeds.rb, due to its complexity
# So if that file changes, we'll need to update this file by hand

puts "      === Validating data from db/seeds/team_ali_code_seeds.rb ==="

# Validate the Scope/ALI tree

# Start an id counter to check for unexpected ids
id_count = 0

# Validate the root nodes, these are top level categories
puts "        team_ali_codes (root)"

row_does_not_exist = TeamAliCode.find_by(:name => 'Capital',    :code => '1X.XX.XX').nil?
row_is_not_unique = TeamAliCode.where(:name => 'Capital',    :code => '1X.XX.XX').count > 1

row_has_an_unexpected_id = false
id_count += 1
unless row_does_not_exist || row_is_not_unique
  row_has_an_unexpected_id = TeamAliCode.find_by(:name => 'Capital',    :code => '1X.XX.XX').id != id_count
end

puts "          #{{:name => 'Capital',    :code => '1X.XX.XX'}.inspect} does not exist in this environment." if row_does_not_exist
puts "          #{{:name => 'Capital',    :code => '1X.XX.XX'}.inspect} is not unique in this environment." if row_is_not_unique
puts "          #{{:name => 'Capital',    :code => '1X.XX.XX'}.inspect} has an unexpected id in this environment. Got #{TeamAliCode.find_by(:name => 'Capital',    :code => '1X.XX.XX').id}. Expected #{id_count}." if row_has_an_unexpected_id

puts "        team_ali_codes (level 1)"

level_1 = [
  {:name => 'Bus',        :code => '11.XX.XX', :parent_code => '1X.XX.XX'},
  {:name => 'Rail',       :code => '12.XX.XX', :parent_code => '1X.XX.XX'},
  {:name => 'New Start',  :code => '14.XX.XX', :parent_code => '1X.XX.XX'}
]
level_1.each do |row|

  filtered_row = row.except(:parent_code)
  filtered_row[:parent_id] = TeamAliCode.find_by_code(row[:parent_code]).try(:id)
  row_does_not_exist = TeamAliCode.find_by(filtered_row).nil?
  row_is_not_unique = TeamAliCode.where(filtered_row).count > 1
  parent_not_found = filtered_row[:parent_id].nil?

  row_has_an_unexpected_id = false
  id_count += 1
  unless row_does_not_exist || row_is_not_unique
    row_has_an_unexpected_id = TeamAliCode.find_by(filtered_row).id != id_count
  end

  puts "          #{row.inspect} does not exist in this environment." if row_does_not_exist
  puts "          #{row.inspect} is not unique in this environment." if row_is_not_unique
  puts "          #{row.inspect} does not have a parent in this environment. Searched TeamAliCode by code, using: #{row[:parent_code]}." if parent_not_found
  puts "          #{row.inspect} has an unexpected id in this environment. Got #{TeamAliCode.find_by(filtered_row).id}. Expected #{id_count}." if row_has_an_unexpected_id
end

# Level 2 for Bus and Fixed Guideways
puts "        team_ali_codes (level 2)"

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
# Validate the second level for each of the bus and fixed guideway nodes
%w{11.XX.XX 12.XX.XX}.each do |parent_code|
  parent = TeamAliCode.find_by_code(parent_code)
  level_2.each do |h|
    pc = parent_code.split('.')[0]
    tc = h[:cat_code].split('.')[1]
    ac = h[:cat_code].split('.')[2]
    code = "#{pc}.#{tc}.#{ac}"

    row = {name: h[:name], code: code, parent_id: parent.try(:id)}
    row_does_not_exist = TeamAliCode.find_by(row).nil?
    row_is_not_unique = TeamAliCode.where(row).count > 1
    parent_not_found = row[:parent_id].nil?

    row_has_an_unexpected_id = false
    id_count += 1
    unless row_does_not_exist || row_is_not_unique
      row_has_an_unexpected_id = TeamAliCode.find_by(row).id != id_count
    end

    puts "          #{row.inspect} does not exist in this environment." if row_does_not_exist
    puts "          #{row.inspect} is not unique in this environment." if row_is_not_unique
    puts "          #{row.inspect} does not have a parent in this environment. Searched TeamAliCode by code, using: #{parent_code}." if parent_not_found
    puts "          #{row.inspect} has an unexpected id in this environment. Got #{TeamAliCode.find_by(row).id}. Expected #{id_count}." if row_has_an_unexpected_id
  end
end

# Third level for rolling stock only
puts "        team_ali_codes (level 3)"

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
# Validate the third level for each of the bus and fixed guideway nodes
%w{11.1X.XX 12.1X.XX}.each do |parent_code|
  parent = TeamAliCode.find_by_code(parent_code)
  level_3_rrs.each do |h|
    pc = parent_code.split('.')[0]
    tc = h[:cat_code].split('.')[1]
    ac = h[:cat_code].split('.')[2]
    code = "#{pc}.#{tc}.#{ac}"
    
    row = {name: h[:name], code: code, parent_id: parent.try(:id)}
    row_does_not_exist = TeamAliCode.find_by(row).nil?
    row_is_not_unique = TeamAliCode.where(row).count > 1
    parent_not_found = row[:parent_id].nil?

    row_has_an_unexpected_id = false
    id_count += 1
    unless row_does_not_exist || row_is_not_unique
      row_has_an_unexpected_id = TeamAliCode.find_by(row).id != id_count
    end

    puts "          #{row.inspect} does not exist in this environment." if row_does_not_exist
    puts "          #{row.inspect} is not unique in this environment." if row_is_not_unique
    puts "          #{row.inspect} does not have a parent in this environment. Searched TeamAliCode by code, using: #{parent_code}." if parent_not_found
    puts "          #{row.inspect} has an unexpected id in this environment. Got #{TeamAliCode.find_by(row).id}. Expected #{id_count}." if row_has_an_unexpected_id
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

# Validate the third level for each of the bus and fixed guideway nodes
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

      row = {name: h[:name], code: code, parent_id: parent.try(:id)}
      row_does_not_exist = TeamAliCode.find_by(row).nil?
      row_is_not_unique = TeamAliCode.where(row).count > 1
      parent_not_found = row[:parent_id].nil?

      row_has_an_unexpected_id = false
      id_count += 1
      unless row_does_not_exist || row_is_not_unique
        row_has_an_unexpected_id = TeamAliCode.find_by(row).id != id_count
      end

      puts "          #{row.inspect} does not exist in this environment." if row_does_not_exist
      puts "          #{row.inspect} is not unique in this environment." if row_is_not_unique
      puts "          #{row.inspect} does not have a parent in this environment. Searched TeamAliCode by code, using: #{parent_code}." if parent_not_found
      puts "          #{row.inspect} has an unexpected id in this environment. Got #{TeamAliCode.find_by(row).id}. Expected #{id_count}." if row_has_an_unexpected_id
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
# Validate the third level for each of the bus and fixed guideway nodes for enhancements
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

      row = {name: h[:name], code: code, parent_id: parent.try(:id)}
      row_does_not_exist = TeamAliCode.find_by(row).nil?
      row_is_not_unique = TeamAliCode.where(row).count > 1
      parent_not_found = row[:parent_id].nil?

      row_has_an_unexpected_id = false
      id_count += 1
      unless row_does_not_exist || row_is_not_unique
        row_has_an_unexpected_id = TeamAliCode.find_by(row).id != id_count
      end

      puts "          #{row.inspect} does not exist in this environment." if row_does_not_exist
      puts "          #{row.inspect} is not unique in this environment." if row_is_not_unique
      puts "          #{row.inspect} does not have a parent in this environment. Searched TeamAliCode by code, using: #{parent_code}." if parent_not_found
      puts "          #{row.inspect} has an unexpected id in this environment. Got #{TeamAliCode.find_by(row).id}. Expected #{id_count}." if row_has_an_unexpected_id
    end
  end
end

# Validate the asset subtypes for the revenue rolling stock

puts "        team_ali_codes (level 4)"

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

      row = {name: h[:name], code: code, parent_id: parent.try(:id)}
      row_does_not_exist = TeamAliCode.find_by(row).nil?
      row_is_not_unique = TeamAliCode.where(row).count > 1
      parent_not_found = row[:parent_id].nil?

      row_has_an_unexpected_id = false
      id_count += 1
      unless row_does_not_exist || row_is_not_unique
        row_has_an_unexpected_id = TeamAliCode.find_by(row).id != id_count
      end

      puts "          #{row.inspect} does not exist in this environment." if row_does_not_exist
      puts "          #{row.inspect} is not unique in this environment." if row_is_not_unique
      puts "          #{row.inspect} does not have a parent in this environment. Searched TeamAliCode by code, using: #{parent_code}." if parent_not_found
      puts "          #{row.inspect} has an unexpected id in this environment. Got #{TeamAliCode.find_by(row).id}. Expected #{id_count}." if row_has_an_unexpected_id
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

      row = {name: h[:name], code: code, parent_id: parent.try(:id)}
      row_does_not_exist = TeamAliCode.find_by(row).nil?
      row_is_not_unique = TeamAliCode.where(row).count > 1
      parent_not_found = row[:parent_id].nil?

      row_has_an_unexpected_id = false
      id_count += 1
      unless row_does_not_exist || row_is_not_unique
        row_has_an_unexpected_id = TeamAliCode.find_by(row).id != id_count
      end

      puts "          #{row.inspect} does not exist in this environment." if row_does_not_exist
      puts "          #{row.inspect} is not unique in this environment." if row_is_not_unique
      puts "          #{row.inspect} does not have a parent in this environment. Searched TeamAliCode by code, using: #{parent_code}." if parent_not_found
      puts "          #{row.inspect} has an unexpected id in this environment. Got #{TeamAliCode.find_by(row).id}. Expected #{id_count}." if row_has_an_unexpected_id
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

      row = {name: h[:name], code: code, parent_id: parent.try(:id)}
      row_does_not_exist = TeamAliCode.find_by(row).nil?
      row_is_not_unique = TeamAliCode.where(row).count > 1
      parent_not_found = row[:parent_id].nil?

      row_has_an_unexpected_id = false
      id_count += 1
      unless row_does_not_exist || row_is_not_unique
        row_has_an_unexpected_id = TeamAliCode.find_by(row).id != id_count
      end

      puts "          #{row.inspect} does not exist in this environment." if row_does_not_exist
      puts "          #{row.inspect} is not unique in this environment." if row_is_not_unique
      puts "          #{row.inspect} does not have a parent in this environment. Searched TeamAliCode by code, using: #{parent_code}." if parent_not_found
      puts "          #{row.inspect} has an unexpected id in this environment. Got #{TeamAliCode.find_by(row).id}. Expected #{id_count}." if row_has_an_unexpected_id
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

      row = {name: h[:name], code: code, parent_id: parent.try(:id)}
      row_does_not_exist = TeamAliCode.find_by(row).nil?
      row_is_not_unique = TeamAliCode.where(row).count > 1
      parent_not_found = row[:parent_id].nil?

      row_has_an_unexpected_id = false
      id_count += 1
      unless row_does_not_exist || row_is_not_unique
        row_has_an_unexpected_id = TeamAliCode.find_by(row).id != id_count
      end

      puts "          #{row.inspect} does not exist in this environment." if row_does_not_exist
      puts "          #{row.inspect} is not unique in this environment." if row_is_not_unique
      puts "          #{row.inspect} does not have a parent in this environment. Searched TeamAliCode by code, using: #{parent_code}." if parent_not_found
      puts "          #{row.inspect} has an unexpected id in this environment. Got #{TeamAliCode.find_by(row).id}. Expected #{id_count}." if row_has_an_unexpected_id
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

      row = {name: h[:name], code: code, parent_id: parent.try(:id)}
      row_does_not_exist = TeamAliCode.find_by(row).nil?
      row_is_not_unique = TeamAliCode.where(row).count > 1
      parent_not_found = row[:parent_id].nil?

      row_has_an_unexpected_id = false
      id_count += 1
      unless row_does_not_exist || row_is_not_unique
        row_has_an_unexpected_id = TeamAliCode.find_by(row).id != id_count
      end

      puts "          #{row.inspect} does not exist in this environment." if row_does_not_exist
      puts "          #{row.inspect} is not unique in this environment." if row_is_not_unique
      puts "          #{row.inspect} does not have a parent in this environment. Searched TeamAliCode by code, using: #{parent_code}." if parent_not_found
      puts "          #{row.inspect} has an unexpected id in this environment. Got #{TeamAliCode.find_by(row).id}. Expected #{id_count}." if row_has_an_unexpected_id
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

      row = {name: h[:name], code: code, parent_id: parent.try(:id)}
      row_does_not_exist = TeamAliCode.find_by(row).nil?
      row_is_not_unique = TeamAliCode.where(row).count > 1
      parent_not_found = row[:parent_id].nil?

      row_has_an_unexpected_id = false
      id_count += 1
      unless row_does_not_exist || row_is_not_unique
        row_has_an_unexpected_id = TeamAliCode.find_by(row).id != id_count
      end

      puts "          #{row.inspect} does not exist in this environment." if row_does_not_exist
      puts "          #{row.inspect} is not unique in this environment." if row_is_not_unique
      puts "          #{row.inspect} does not have a parent in this environment. Searched TeamAliCode by code, using: #{parent_code}." if parent_not_found
      puts "          #{row.inspect} has an unexpected id in this environment. Got #{TeamAliCode.find_by(row).id}. Expected #{id_count}." if row_has_an_unexpected_id
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
      
      row = {name: h[:name], code: code, parent_id: parent.try(:id)}
      row_does_not_exist = TeamAliCode.find_by(row).nil?
      row_is_not_unique = TeamAliCode.where(row).count > 1
      parent_not_found = row[:parent_id].nil?

      row_has_an_unexpected_id = false
      id_count += 1
      unless row_does_not_exist || row_is_not_unique
        row_has_an_unexpected_id = TeamAliCode.find_by(row).id != id_count
      end

      puts "          #{row.inspect} does not exist in this environment." if row_does_not_exist
      puts "          #{row.inspect} is not unique in this environment." if row_is_not_unique
      puts "          #{row.inspect} does not have a parent in this environment. Searched TeamAliCode by code, using: #{parent_code}." if parent_not_found
      puts "          #{row.inspect} has an unexpected id in this environment. Got #{TeamAliCode.find_by(row).id}. Expected #{id_count}." if row_has_an_unexpected_id
    end
  end
end
