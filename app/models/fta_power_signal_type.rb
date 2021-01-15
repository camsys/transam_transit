class FtaPowerSignalType < ApplicationRecord

  belongs_to :fta_asset_class
  has_many :asset_subtypes, as: :fta_type, inverse_of: :fta_type

  # All types that are available
  scope :active, -> { where(:active => true) }
  scope :sorted, -> { order(:sort_order) }

  def to_s
    name
  end
end
