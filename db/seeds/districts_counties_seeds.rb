if DistrictType.find_by(name: 'County')

  filename = File.join(TransamTransit::Engine.root,"db/data", 'counties.csv')
  puts "Processing #{filename}"

  state = Grantor.first.state
  county_district = DistrictType.find_by(name: 'County')

  new_dists = []
  CSV.foreach(filename, :headers => true, :col_sep => "," ) do |row|
    dist = District.find_by(name: row[0])
    unless dist.present?
      dist = District.new
    end

    dist.district_type = county_district
    dist.name = row[0].strip
    dist.description = row[1].strip == 'County' ? row[0] : "#{row[0]} #{row[1]}"
    dist.state = ISO3166::Country['US'].states.find{|k,x| x.name == row[2].strip}[0]
    if dist.state.blank?
      puts "cannot find state #{row[2]}"
    else
      dist.active = (dist.state == state)
      new_dists << dist if dist.save!
    end

  end
end
