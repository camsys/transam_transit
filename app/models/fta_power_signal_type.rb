class FtaPowerSignalType < ApplicationRecord

  belongs_to :fta_asset_class

  # All types that are available
  scope :active, -> { where(:active => true) }
  scope :sorted, -> { order(:sort_order) }

  def to_s
    name
  end
end
