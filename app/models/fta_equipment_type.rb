class FtaEquipmentType < ApplicationRecord

  belongs_to :fta_asset_class

  # All types that are available
  scope :active, -> { where(:active => true) }

end
