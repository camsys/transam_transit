class AddRailSeedRegardlessAppConfig < ActiveRecord::DataMigration
  def up

    if AssetType.find_by(class_name: 'RailCar').nil?
      require_relative File.join("../seeds", 'rail.seeds') # Rail asset types/subtypes are seeded from a separate file

      rail_cars = Manufacturer.where(filter: 'Vehicle').map{|x| x.attributes.except('id').merge({filter: 'RailCar'})}
      locomotives = Manufacturer.where(filter: 'Vehicle').map{|x| x.attributes.except('id').merge({filter: 'Locomotive'})}
      (rail_cars + locomotives).each do |manufacturer|
        Manufacturer.create!(manufacturer)
      end
    end
  end
end