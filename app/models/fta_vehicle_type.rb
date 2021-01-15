class FtaVehicleType < ActiveRecord::Base

  belongs_to :fta_asset_class
  has_many :asset_subtypes, as: :fta_type, inverse_of: :fta_type
  
  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { order(:name) }

  # All types that are available
  scope :active, -> { where(:active => true) }

  def self.search(text, exact = true)
    if exact
      x = where('name = ? OR code = ? OR description = ?', text, text, text).first
    else
      val = "%#{text}%"
      x = where('name LIKE ? OR code LIKE ? OR description LIKE ?', val, val, val).first
    end
    x
  end

  def to_s
    "#{code}-#{name}"
  end

end
