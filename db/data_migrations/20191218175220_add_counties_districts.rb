class AddCountiesDistricts < ActiveRecord::DataMigration
  def up

    District.where(district_type: DistrictType.find_by(name: 'County'), state: nil).update_all(state: SystemConfig.instance.try(:default_state_code), active: false)

    require TransamTransit::Engine.root.join('db', 'seeds', 'districts_counties_seeds.rb')

    old_county_districts = District.where(district_type: DistrictType.find_by(name: 'County'), state: SystemConfig.instance.try(:default_state_code), active: false)

    if old_county_districts.count > 0
      puts "Bad counties: #{old_county_districts.inspect}"
      puts "#{TransitAsset.joins(:districts).where(districts: {id: old_county_districts}).count} assets use invalid counties"
      puts "#{CapitalProject.joins(:districts).where(districts: {id: old_county_districts}).count} capital projects use invalid counties"     if SystemConfig.transam_module_names.include? 'cpt'

      puts "#{FtaAgency.joins(:districts).where(districts: {id: old_county_districts}).count} organizations use invalid counties"
      District.where(id: old_county_districts).destroy_all
    end

    # make all counties not belonging to the state inactive
    District.where(district_type: DistrictType.find_by(name: 'County')).where.not(state: SystemConfig.instance.try(:default_state_code)).update_all(active: false)
  end
end