class ComponentMaterial < ApplicationRecord

  belongs_to :component_type
  belongs_to :new_component_subtype

  # All types that are available
  scope :active, -> { where(:active => true) }

  def to_s
    name
  end

end
