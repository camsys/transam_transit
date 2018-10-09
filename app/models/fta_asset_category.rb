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
    if (asset_types & AssetType.where(class_name: ['Track', 'Guideway', 'PowerSignal'])).count > 0
      categories << 'Infrastructure'
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
    elsif name == 'Infrastructure'
      AssetType.where(class_name: ['Track', 'Guideway', 'PowerSignal'])
    end
  end


  def asset_levels(assets=nil)
    if name == 'Revenue Vehicles'
      asset_level = FtaVehicleType.all
    elsif name == 'Equipment'
      asset_level = FtaSupportVehicleType.all
    elsif name == 'Facilities'
      asset_level = self.fta_asset_classes
    elsif name == 'Infrastructure'
      asset_level = FtaModeType.all
    end

    if asset_level.present?
      if assets.present? && assets.distinct.pluck(:fta_asset_category_id) == [self.id] # make sure all assets are within fta asset category
        if name == 'Facilities'
          asset_level.where(id: assets.distinct.pluck(:fta_asset_class_id))
        elsif name == 'Infrastructure'
          asset_level.where(id: AssetsFtaModeType.where(asset_id: assets.very_specific.ids, is_primary: true).pluck(:fta_mode_type_id))
        else
          asset_level.where(id: assets.distinct.where(fta_type_type: asset_level.klass.to_s).pluck(:fta_type_id))
        end
      else
        asset_level
      end
    end
  end

  def asset_search_query(asset_level)
    if name == 'Facilities'
      {fta_asset_class_id: asset_level.id}
    elsif name != 'Infrastructure'
      {fta_type_type: asset_level.class.name, fta_type_id: asset_level.id}
    end
  end

  def to_s
    name
  end




end
