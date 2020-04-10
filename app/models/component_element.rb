class ComponentElement < ApplicationRecord

  belongs_to :parent, polymorphic: true

  # All types that are available
  scope :active, -> { where(:active => true) }

  def to_s
    name
  end

  def api_json(options={})
    {
      id: id,
      parent_type: parent_type,
      parent: parent.try(:api_json, options),
      name: name
    }
  end

end
