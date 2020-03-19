class FacilityFeature < ActiveRecord::Base

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
    "#{code}-#{name}"
  end

  ######## API Serializer ##############
  def api_json(options={})
    {
      id: id,
      name: name,
      code: code,
      description: description
    }
  end

end
