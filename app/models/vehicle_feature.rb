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
      "enum": VehicleFeature.all.pluck(:name),
      "tuple": VehicleFeature.all.map{ |x| {"id": x.id, "val": x.name} },
      "type": "string",
      "title": "Vehicle Feature"
    }
  end

end
