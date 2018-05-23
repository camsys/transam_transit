class FtaAssetClass < ApplicationRecord

  belongs_to  :fta_asset_category

  # All types that are available
  scope :active, -> { where(:active => true) }

end
