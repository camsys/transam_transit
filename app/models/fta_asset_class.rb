class FtaAssetClass < ApplicationRecord

  belongs_to  :fta_asset_category

  # All types that are available
  scope :active, -> { where(:active => true) }

  def to_s
    name
  end

  # override column in database as other
  def class_name(opts={})
    if fta_asset_category.name == 'Facilities' && opts[:facility_component_type_id].to_i > 0
      'FacilityComponent'
    else
      read_attribute(:class_name)
    end
  end
end
