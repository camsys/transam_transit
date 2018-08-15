class ComponentMaterial < ApplicationRecord

  belongs_to :component_type
  belongs_to :component_element_type

  # All types that are available
  scope :active, -> { where(:active => true) }

  def to_s
    name
  end

end
