class FtaAgencyType < ActiveRecord::Base
    
  # default scope
  default_scope { where(:active => true) }

  def self.search(text, exact = true)
    if exact
      x = where('name = ? OR description = ?', text, text).first
    else
      val = "%#{text}%"
      x = where('name = LIKE ? OR description LIKE ?', val, val).first
    end
    x
  end

  def to_s
    name
  end

end

