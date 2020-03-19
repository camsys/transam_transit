class FtaAssetClass < ApplicationRecord

  belongs_to  :fta_asset_category

  # All types that are available
  scope :active, -> { where(:active => true) }

  def to_s
    name
  end

  # override column in database as other
  def class_name(opts: {},assets: nil)
    if fta_asset_category.name == 'Facilities'
      if opts[:is_component].to_i != TransitAsset::CATEGORIZATION_PRIMARY
        'FacilityComponent'
      elsif assets.present? && (assets.very_specific.class.to_s.include? 'Component') # asset.very_specific class might be already highest class since cached not just the class as determined from DB table name so check if contains Component and can be either FacilityComponent or TransitComponent
        'FacilityComponent'
      else
        read_attribute(:class_name)
      end
    elsif fta_asset_category.name == 'Infrastructure'
      if assets.present? && (assets.very_specific.class.to_s.include? 'Component')
        'InfrastructureComponent'
      else
        read_attribute(:class_name)
      end
    else
      read_attribute(:class_name)
    end
  end

  def is_bus?
    name == 'Buses (Rubber Tire Vehicles)'
  end

  def api_json(options={})
    {
      id: id,
      name: name,
      fta_asset_category: fta_asset_category.api_json
    }
  end
end
