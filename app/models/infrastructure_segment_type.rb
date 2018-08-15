class InfrastructureSegmentType < ApplicationRecord

  belongs_to :fta_asset_class
  belongs_to :asset_subtype

  # All types that are available
  scope :active, -> { where(:active => true) }


end
