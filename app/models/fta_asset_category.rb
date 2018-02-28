class FtaAssetCategory < ActiveRecord::Base

  # All types that are available
  scope :active, -> { where(:active => true) }

  def to_s
    name
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

  def default_useful_life_benchmark_with_unit
    if name == 'Revenue Vehicles'
      [14, 'year']
    elsif name == 'Facilities'
      [3, 'condition_rating']
    end
  end

end
