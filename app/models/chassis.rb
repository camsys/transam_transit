class Chassis < ApplicationRecord

  # All types that are available
  scope :active, -> { where(:active => true) }

  def to_s
    name
  end

  def api_json(options={})
    as_json(options)
  end

  #for bulk updates
  def self.schema_structure
    {
      "enum": Chassis.all.pluck(:name),
      "tuple": Chassis.all.map{|c| {"id": c.id, "val": c.name } },
      "type": "string",
      "title": "Chassis"
    }
  end


end
