class FtaAssetCategory < ActiveRecord::Base

  # All types that are available
  scope :active, -> { where(:active => true) }

  def self.asset_types(asset_types=AssetType.none)
    categories = []
    if (asset_types & AssetType.where(class_name: ['Vehicle', 'Locomotive', 'RailCar'])).count > 0
      categories << 'Revenue Vehicles'
    elsif (asset_types & AssetType.where(class_name: ['Equipment', 'SupportVehicle'])).count > 0
      categories << 'Equipment'
    elsif (asset_types & AssetType.where(class_name: ['TransitFacility', 'SupportFacility'])).count > 0
      categories << 'Facilities'
    end

    FtaAssetCategory.where(name: categories)
  end

  # this is a temporary method to map new asset hierarchy (following fta) to original asset types
  def asset_types
    if name == 'Revenue Vehicles'
      AssetType.where(class_name: ['Vehicle', 'Locomotive', 'RailCar'])
    elsif name == 'Equipment'
      AssetType.where(class_name: ['Equipment', 'SupportVehicle'])
    elsif name == 'Facilities'
      AssetType.where(class_name: ['TransitFacility', 'SupportFacility'])
    end
  end

  def class_or_types
    if name == 'Revenue Vehicles'
      FtaVehicleType.all
    elsif name == 'Equipment'
      FtaSupportVehicleType.all
    elsif name == 'Facilities'
      # TODO need to actually use class not type
      FtaFacilityType.all
    end
  end

  def default_useful_life_benchmark_with_unit
    if name == 'Revenue Vehicles'
      [14, 'year']
    elsif name == 'Facilities'
      [3, 'condition_rating']
    end
  end

  def to_s
    name
  end


end
