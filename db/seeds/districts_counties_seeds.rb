if DistrictType.find_by(name: 'County')

  filename = File.join(TransamTransit::Engine.root,"db/data", 'counties.csv')
  puts "Processing #{filename}"

  county_district = DistrictType.find_by(name: 'County')

  CSV.foreach(filename, :headers => true, :col_sep => "," ) do |row|
    state =  ISO3166::Country['US'].states.find{|k,x| x.name == row[2].strip}[0]
    if state
      dist = District.find_or_initialize_by(name: row[0], district_type: county_district, state:state)
      dist.description = row[1].strip == 'County' ? row[0] : "#{row[0]} #{row[1]}"
      dist.active = true
      dist.save!
    else
      puts "cannot find state #{row[2]}"
    end

  end
end
