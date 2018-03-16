#
# A TAM Group has many FTA asset categories
# As new asset profiles haven't been done yet, there is no link between the new FTA asset category-class-type hierarchy
# Temporarily I store all methods here to do searches between category-class-type and assets here
# asset_level is always at the class or type level based on whether the category is facility or not



class FtaAssetCategory < ActiveRecord::Base

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
      asset_level = FtaFacilityType.where(name: ["Administrative Office/Sales Office",  "General Purpose Maintenance Facility/Depot", "Bus Transfer Station", "Parking Structure"])
    end

    if assets.present?
      if name == 'Facilities'

        fta_facility_type_ids = assets.distinct.pluck(:fta_facility_type_id)

        org_types = []

        unless (fta_facility_type_ids & FtaFacilityType.where(name: ["Administrative Office/Sales Office","Combined Administrative and Maintenance Facility", "Revenue Collection Facility","Other, Administrative & Maintenance"]).pluck(:id)).empty?
          org_types << "Administrative Office/Sales Office"
        end
        unless (fta_facility_type_ids & FtaFacilityType.where(name: [ "General Purpose Maintenance Facility/Depot",  "Heavy Maintenance and Overhaul (Backshop)","Maintenance Facility (Service and Inspection)", "Vehicle Blow-Down Facility", "Vehicle Fueling Facility", "Vehicle Testing Facility", "Vehicle Washing Facility"]).pluck(:id)).empty?
          org_types <<  "General Purpose Maintenance Facility/Depot"
        end
        unless (fta_facility_type_ids & FtaFacilityType.where(name: ["At-Grade Fixed Guideway Station","Bus Transfer Station","Elevated Fixed Guideway Station", "Exclusive Grade-Separated Platform Station","Simple At-Grade Platform Station", "Underground Fixed Guideway Station"]).pluck(:id)).empty?
          org_types << "Bus Transfer Station"
        end
        unless (fta_facility_type_ids & FtaFacilityType.where(name: [ "Parking Structure","Surface Parking Lot","Other, Passenger or Parking"]).pluck(:id)).empty?
          org_types << "Parking Structure"
        end

        asset_level.where(name: org_types)

      else
        asset_level.where(id: assets.distinct.pluck("#{asset_level.name.underscore}_id"))
      end
    end
  end

  def asset_search_query(asset_level)
    asset_query = Hash.new

    if name == 'Facilities'
      facility_types = []

      if asset_level == FtaFacilityType.find_by(name: "Administrative Office/Sales Office")
        facility_types << FtaFacilityType.where(name: ["Administrative Office/Sales Office","Combined Administrative and Maintenance Facility", "Revenue Collection Facility","Other, Administrative & Maintenance"]).pluck(:id)
      end
      if asset_level == FtaFacilityType.find_by(name: "General Purpose Maintenance Facility/Depot")
        facility_types << FtaFacilityType.where(name: [ "General Purpose Maintenance Facility/Depot",  "Heavy Maintenance and Overhaul (Backshop)","Maintenance Facility (Service and Inspection)", "Vehicle Blow-Down Facility", "Vehicle Fueling Facility", "Vehicle Testing Facility", "Vehicle Washing Facility"]).pluck(:id)
      end
      if asset_level == FtaFacilityType.find_by(name: "Bus Transfer Station")
        facility_types << FtaFacilityType.where(name: ["At-Grade Fixed Guideway Station","Bus Transfer Station","Elevated Fixed Guideway Station", "Exclusive Grade-Separated Platform Station","Simple At-Grade Platform Station", "Underground Fixed Guideway Station"]).pluck(:id)
      end
      if asset_level == FtaFacilityType.find_by(name: "Parking Structure")
        facility_types << FtaFacilityType.where(name: [ "Parking Structure","Surface Parking Lot","Other, Passenger or Parking"]).pluck(:id)
      end

      asset_query[asset_level.class.name.underscore+'_id'] = facility_types.flatten
    else
      asset_query[asset_level.class.name.underscore+'_id'] = asset_level.id
    end

    asset_query
  end

  def get_asset_level_label(asset_level)
    if name == 'Facilities'
      if asset_level == FtaFacilityType.find_by(name:"Administrative Office/Sales Office")
        'Administration'
      elsif asset_level == FtaFacilityType.find_by(name:"General Purpose Maintenance Facility/Depot")
        'Maintenance'
      elsif asset_level == FtaFacilityType.find_by(name:"Bus Transfer Station")
        'Passenger'
      elsif asset_level == FtaFacilityType.find_by(name:"Parking Structure")
        'Parking'
      end
    else
      asset_level.to_s
    end

  end

  def to_s
    name
  end




end
