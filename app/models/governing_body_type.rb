#------------------------------------------------------------------------------
#
# GoverningBodyType
#
# Lookup Table for types of governing bodies.
#
#------------------------------------------------------------------------------

class GoverningBodyType < ActiveRecord::Base

  # All types that are available
  scope :active, -> { where(:active => true) }

  def to_s
    name
  end

end
