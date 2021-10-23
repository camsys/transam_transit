class FtaSupportVehicleType < ActiveRecord::Base

  belongs_to :fta_asset_class
  has_many :fta_type_asset_subtype_mappings, as: :fta_type
  has_many :asset_subtypes, through: :fta_type_asset_subtype_mappings

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { order(:name) }

  # All types that are available
  scope :active, -> { where(:active => true) }

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

  # for bulk updates
  def self.schema_structure
    {
        "enum": FtaSupportVehicleType.all.pluck(:name),
        "tuple": FtaSupportVehicleType.all.map{ |x| {"id": x.id, "val": x.name} },
        "type": "string",
        "title": "Type"
    }
  end

end
