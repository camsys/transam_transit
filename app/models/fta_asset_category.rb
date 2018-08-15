#
# A TAM Group has many FTA asset categories
# As new asset profiles haven't been done yet, there is no link between the new FTA asset category-class-type hierarchy
# Temporarily I store all methods here to do searches between category-class-type and assets here
# asset_level is always at the class or type level based on whether the category is facility or not



class FtaAssetCategory < ActiveRecord::Base

  has_many :fta_asset_classes

  # All types that are available
  scope :active, -> { where(:active => true) }

  def self.asset_types(asset_types=AssetType.none)
    categories = []
    if (asset_types & AssetType.where(class_name: ['Vehicle', 'Locomotive', 'RailCar'])).count > 0
      categories << 'Revenue Vehicles'
    end
    if (asset_types & AssetType.where(class_name: ['Equipment', 'SupportVehicle'])).count > 0
      categories << 'Equipment'
    end
    if (asset_types & AssetType.where(class_name: ['TransitFacility', 'SupportFacility'])).count > 0
      categories << 'Facilities'
    end

    FtaAssetCategory.where(name: categories)
  end


  def asset_types
    if name == 'Revenue Vehicles'
      AssetType.where(class_name: ['Vehicle', 'Locomotive', 'RailCar'])
    elsif name == 'Equipment'
      AssetType.where(class_name: ['Equipment', 'SupportVehicle'])
    elsif name == 'Facilities'
      AssetType.where(class_name: ['TransitFacility', 'SupportFacility'])
    end
  end


  def asset_levels(assets=nil)
    if name == 'Revenue Vehicles'
      asset_level = FtaVehicleType.all
    elsif name == 'Equipment'
      asset_level = FtaSupportVehicleType.all
    elsif name == 'Facilities'
      asset_level = FtaFacilityType.all
    end

    if assets.present?
      asset_level.where(id: assets.distinct.pluck(:fta_type_id))
    else
      asset_level
    end
  end

  def asset_search_query(asset_level)
    asset_query = Hash.new

    asset_query[asset_level.class.name.underscore+'_id'] = asset_level.id

    asset_query
  end

  def to_s
    name
  end




end
