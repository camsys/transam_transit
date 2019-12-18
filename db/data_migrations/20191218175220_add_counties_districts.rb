class AddCountiesDistricts < ActiveRecord::DataMigration
  def up
    old_county_districts = District.where(district_type: DistrictType.find_by(name: 'County')).pluck(:id)

    require TransamTransit::Engine.root.join('db', 'seeds', 'districts_counties_seeds.rb')

    old_county_districts = (old_county_districts - new_dists.map{|x| x.id})
    if old_county_districts.count > 0
      puts "#{TransitAsset.joins(:districts).where(districts: {id: old_county_districts}).count} assets use invalid counties"
      puts "#{CapitalProject.joins(:districts).where(districts: {id: old_county_districts}).count} capital projects use invalid counties" if SystemConfig.transam_module_names.include? 'cpt'

      District.where(id: old_county_districts).destroy_all
    end
  end
end