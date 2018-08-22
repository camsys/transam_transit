class AddGenericUzaDistricts < ActiveRecord::DataMigration
  def up
    uza = DistrictType.find_or_initialize_by(name: 'UZA')
    uza.update!(description: 'UZA',active: true)

    District.create!(district_type: uza, name: 'Rural', code: 'Rural', description: 'Rural', active: true)
    District.create!(district_type: uza, name: 'Statewide', code: 'State', description: 'Statewide', active: true)
  end
end