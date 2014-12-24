class FuelType < ActiveRecord::Base
    
  #attr_accessible :name, :description, :code, :active
        
  # default scope
  default_scope { where(:active => true) }

  searchable do
    text :code, :description
  end

  def to_s
    name
  end

end

