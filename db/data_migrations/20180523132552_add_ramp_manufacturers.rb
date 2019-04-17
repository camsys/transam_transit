class AddRampManufacturers < ActiveRecord::DataMigration
  def up
    ramp_manufacturers = [
        {name: 'Braun', active: true},
        {name: 'Ricon', active: true},
        {name: 'Other', active: true}
    ]

    ramp_manufacturers.each do |manufacturer|
      RampManufacturer.create!(manufacturer)
    end
  end
end