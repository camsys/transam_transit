class ComponentSubtype < ApplicationRecord

  belongs_to :parent, polymorphic: true

  # All types that are available
  scope :active, -> { where(:active => true) }

  def to_s
    name
  end
end
