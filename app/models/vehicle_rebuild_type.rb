#------------------------------------------------------------------------------
#
# VehicleRebuildType
#
# Lookup Table for vehicle rebuild types.
#
#------------------------------------------------------------------------------

class VehicleRebuildType < ActiveRecord::Base

  # All types that are available
  scope :active, -> { where(:active => true) }

  def to_s
    name
  end

end
