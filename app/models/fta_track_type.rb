class FtaTrackType < ApplicationRecord

  belongs_to :fta_asset_class
  has_many :fta_type_asset_subtype_mappings, as: :fta_type
  has_many :asset_subtypes, through: :fta_type_asset_subtype_mappings

  # All types that are available
  scope :active, -> { where(:active => true) }
  scope :sorted, -> { order(:sort_order) }

  def to_s
    name
  end

end
