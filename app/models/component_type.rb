class ComponentType < ApplicationRecord

  belongs_to :fta_asset_category
  belongs_to :fta_asset_class

  # All types that are available
  scope :active, -> { where(:active => true) }

  def to_s
    name
  end

  ######## API Serializer ##############
  def api_json(options={})
    {
      id: id,
      fta_asset_class: fta_asset_class.try(:api_json),
      name: name
    }
  end
end
