class FtaFundingType < ActiveRecord::Base

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
    "#{name} (#{code})"
  end

  def api_json(options={})
    {id: id, name: name, code: code, description: description}
  end

  #for bulk updates
  def self.schema_structure 
    {
      "enum": FtaFundingType.all.pluck(:name),
      "tuple": FtaFundingType.all.map{|f| {"id": f.id, "val": f.name } },
      "type": "string",
      "title": "Funding Type"
    }
  end
end
