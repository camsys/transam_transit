class FtaAssetClass < ApplicationRecord

  belongs_to  :fta_asset_category

  # All types that are available
  scope :active, -> { where(:active => true) }

  def to_s
    name
  end

  # override column in database as other
  def class_name
  end
end
