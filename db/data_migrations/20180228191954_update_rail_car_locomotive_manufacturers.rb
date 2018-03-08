class UpdateRailCarLocomotiveManufacturers < ActiveRecord::DataMigration
  def up
    other_manufacturer = Manufacturer.find_by(filter: 'Vehicle', code: 'ZZZ')

    RailCar.all.each do |asset|
      new_manufacturer = Manufacturer.find_by(filter: 'Vehicle', code: asset.manufacturer.try(:code))
      if new_manufacturer.nil?
        asset.other_manufacturer = asset.manufacturer.try(:name)
        asset.manufacturer = other_manufacturer
      else
        asset.manufacturer = new_manufacturer
      end
    end

    Locomotive.all.each do |asset|
      new_manufacturer = Manufacturer.find_by(filter: 'Vehicle', code: asset.manufacturer.try(:code))
      if new_manufacturer.nil?
        asset.other_manufacturer = asset.manufacturer.try(:name)
        asset.manufacturer = other_manufacturer
      else
        asset.manufacturer = new_manufacturer
      end
    end

    Manufacturer.where(filter: ['RailCar', 'Locomotive']).delete_all

  end
end