class VehicleFeature < ActiveRecord::Base

  # Allow selection of active instances
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
    name
  end

  def api_json(options={})
    as_json(options)
  end

  # for bulk updates
  def self.schema_structure # TODO
    {
        "type": "array",
        "title": "Vehicle Features",
        "items": {
            "type": "string",
            "tuple": VehicleFeature.all.map{ |f| {"id": f.id, "val": f.name} }
        }
    }
  end

end
