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
      if opts[:is_component].to_i != Facility::CATEGORIZATION_PRIMARY
        'FacilityComponent'
      elsif assets.present? && (assets.very_specific.class.to_s.include? 'Component')
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
end
