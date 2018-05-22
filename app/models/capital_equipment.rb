class CapitalEquipment < ApplicationRecord
  actable as: :capital_equipmentible

  acts_as :transit_asset, as: :transit_assetible
end
