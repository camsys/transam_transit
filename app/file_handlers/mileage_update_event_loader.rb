#------------------------------------------------------------------------------
#
# Mileage Update Event
#
# Used to process both SOGR updates and new inventory updates
#
#------------------------------------------------------------------------------
class MileageUpdateEventLoader < EventLoader

  CURRENT_MILEAGE_COL   = 0
  EVENT_DATE_COL        = 1

  def process(asset, cells)

    # Create a new MileageUpdateEvent
    @event = asset.build_typed_event(MileageUpdateEvent)

    # Current Mileage
    @event.current_mileage = as_integer(cells[CURRENT_MILEAGE_COL])

    # Event Date
    @event.event_date = as_date(cells[EVENT_DATE_COL])

  end

  private
  def initialize
    super
  end

end
