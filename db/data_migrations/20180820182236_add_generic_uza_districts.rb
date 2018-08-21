class AddGenericUzaDistricts < ActiveRecord::DataMigration
  def up
    District.create!(district_type: DistrictType.find_by(name: 'UZA'), name: 'Rural', code: 'Rural', description: 'Rural', active: true)
    District.create!(district_type: DistrictType.find_by(name: 'UZA'), name: 'Statewide', code: 'State', description: 'Statewide', active: true)
  end
end