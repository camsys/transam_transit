class EslCategory < ApplicationRecord

  # All types that are available
  scope :active, -> { where(:active => true) }

  def to_s
    name
  end

  def api_json(options={})
    {id: id, name: name}  
  end 

  def self.schema_structure
    {
      "enum": EslCategory.all.pluck(:name),
      "tuple": EslCategory.all.map{|e| {"id": e.id, "val": e.name } },
      "type": "string",
      "title": "Estimated Service Life (ESL) Category"
    }
  end

end
