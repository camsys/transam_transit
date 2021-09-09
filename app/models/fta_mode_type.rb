class FtaModeType < ActiveRecord::Base

  # All types that are available
  scope :active, -> { where(:active => true) }

  default_scope { order(:name) }

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
    "#{code} - #{name}"
  end

  def api_json(options={})
    as_json(options)
  end

  # for bulk updates
  def self.schema_structure
    {
      "enum": FtaModeType.all.pluck(:name),
      "tuple": FtaModeType.all.map{ |x| {"id": x.id, "val": x.name} },
      "type": "string",
      "title": "Service Status"
    }
    
  end


end
