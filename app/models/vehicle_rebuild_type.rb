#------------------------------------------------------------------------------
#
# VehicleRebuildType
#
# Lookup Table for vehicle rebuild types.
#
#------------------------------------------------------------------------------

class VehicleRebuildType < ActiveRecord::Base

  # default scope
  default_scope { where(:active => true) }

  def to_s
    name
  end

end
