class FtaFacilityType < ActiveRecord::Base

  belongs_to :fta_asset_class
  has_many :asset_subtypes, as: :fta_type, inverse_of: :fta_type

  # set the default scope
  default_scope { order(:name) }

  # All types that are available
  scope :active, -> { where(:active => true) }

  scope :active_for_asset_type, -> (asset_type) { active.where(class_name: asset_type.class_name) }

  def self.search(text, exact = true)
    if exact
      x = where('name = ? OR description = ?', text, text).first
    else
      val = "%#{text}%"
      x = where('name LIKE ? OR description LIKE ?', val, val).first
    end
    x
  end

  def to_s
    name
  end

end
