class FtaEquipmentType < ApplicationRecord

  belongs_to :fta_asset_class
  has_many :fta_type_asset_subtype_mappings, as: :fta_type
  has_many :asset_subtypes, through: :fta_type_asset_subtype_mappings

  # All types that are available
  scope :active, -> { where(:active => true) }

  def to_s
    name
  end

  # for bulk updates
  def self.schema_structure
    {
        "enum": FtaEquipmentType.all.pluck(:name),
        "tuple": FtaEquipmentType.all.map{ |x| {"id": x.id, "val": x.name} },
        "type": "string"
    }
  end

end
