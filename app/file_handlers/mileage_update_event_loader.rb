#------------------------------------------------------------------------------
#
# MileageUpdateEventLoader
#
# Generic class for processing mileage update events
#
#------------------------------------------------------------------------------
class MileageUpdateEventLoader < EventLoader
  
  MILEAGE_COL           = 0
  EVENT_DATE_COL        = 2 
    
  def process(asset, cells)

    # Create a new MileageUpdateEvent
    @event = asset.build_typed_event(MileageUpdateEvent)

    # Event Date
    @event.event_date = as_date(cells[EVENT_DATE_COL])
    
    # Current Mileage
    @event.current_mileage = as_integer(cells[MILEAGE_COL])
    
  end
  
  private
  def initialize
    super
  end
  
end