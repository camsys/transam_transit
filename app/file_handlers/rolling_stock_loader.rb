#------------------------------------------------------------------------------
#
# RollingStockLoader
#
# Provides additional base class methods for asset loaders that are based on
# the RollingStock class
#
#------------------------------------------------------------------------------
class RollingStockLoader < InventoryLoader

  protected

  # gets a reasonable default length for an asset based on its subtype
  def estimate_vehicle_length(asset)
    name = asset.asset_subtype.name
    if name == 'Bus Std 40 FT'
      length = 40
    elsif name == 'Bus Std 35 FT'
      length = 35
    elsif name == 'Bus 30 FT'
      length = 30
    elsif name == 'Bus < 30 FT'
      length = 25
    elsif name == 'Bus School'
      length = 40
    elsif name == 'Bus Articulated'
      length = 60
    elsif name == 'Bus Articulated'
      length = 60
    elsif name == 'Bus Commuter/Suburban'
      length = 40
    elsif name == 'Bus Intercity'
      length = 40
    elsif name == 'Bus Trolley Std'
      length = 40
    elsif name == 'Bus Trolley Articulated'
      length = 60
    elsif name == 'Bus Double Deck'
      length = 40
    elsif name == 'Van'
      length = 20
    elsif name == 'Sedan/Station Wagon'
      length = 12
    elsif name == 'Ferry Boat'
      length = 100
    elsif name == 'Light Rail Car'
      length = 85
    elsif name == 'Heavy Rail Car'
      length = 85
    elsif name == 'Commuter Rail Self Propelled (Elec)'
      length = 85
    elsif name == 'Commuter Rail Self Propelled (Diesel)'
      length = 85
    elsif name == 'Commuter Rail Car Trailer'
      length = 85
    elsif name == 'Incline Railway Car'
      length = 40
    elsif name == 'Cable Car'
      length = 20
    elsif name == 'Commuter Locomotive Diesel'
      length = 50
    elsif name == 'Commuter Locomotive Electric'
      length = 50
    else
      length = 0
    end
    length
  end

  private

  def initialize
    super
  end

end
