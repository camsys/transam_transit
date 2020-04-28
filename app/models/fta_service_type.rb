class FtaServiceType < ActiveRecord::Base

  #has_and_belongs_to_many :assets

  # All types that are available
  scope :active, -> { where(:active => true) }
  scope :is_primary, -> { joinwhere(:active => true) }

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

end
