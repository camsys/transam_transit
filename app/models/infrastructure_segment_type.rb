class InfrastructureSegmentType < ApplicationRecord

  belongs_to :fta_asset_class
  belongs_to :asset_subtype

  # All types that are available
  scope :active, -> { where(:active => true) }

  def to_s
    name
  end

  def api_json(options={})
    {
      id: id,
      fta_asset_class: fta_asset_class.try(:api_json, options),
      asset_subtype: asset_subtype.try(:api_json, options),
      name: name
    }
  end

end
