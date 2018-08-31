class FtaAssetClass < ApplicationRecord

  belongs_to  :fta_asset_category

  # All types that are available
  scope :active, -> { where(:active => true) }

  def to_s
    name
  end

  # override column in database as other
  def class_name(opts={})
    if fta_asset_category.name == 'Facilities' && opts[:is_component].to_i != Facility::CATEGORIZATION_PRIMARY
      'FacilityComponent'
    else
      read_attribute(:class_name)
    end
  end
end
