class FtaFundingSourceType < ActiveRecord::Base
    
  # default scope
  default_scope { where(:active => true) }

  def self.search(text, exact = true)
    if exact
      x = find_by('name = ? OR description = ?', text, text)
    else
      val = "%#{text}%"
      x = find_by('name LIKE ? OR description LIKE ?', val, val)
    end
    x
  end

  def to_s
    name
  end
end

