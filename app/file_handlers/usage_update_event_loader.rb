#------------------------------------------------------------------------------
#
# UsageUpdateEventLoader
#
# Generic class for processing usage update events
#
#------------------------------------------------------------------------------
class UsageUpdateEventLoader < EventLoader
  
  PCNT_5311_ROUTES_COL          = 0
  AVG_DAILY_USE_COL             = 1 
  AVG_DAILY_PASSENGER_TRIPS_COL = 2
  EVENT_DATE_COL                = 4 
  COMMENTS_COL                  = 5
    
  def process(asset, cells)

    # Create a new UsageUpdateEvent
    @event = asset.build_typed_event(VehicleUsageUpdateEvent)

    # Event Date
    @event.event_date = as_date(cells[EVENT_DATE_COL])

    # PCNT 5311 Routes
    @event.pcnt_5311_routes = as_integer(cells[PCNT_5311_ROUTES_COL])

    # Avg Daily Use
    @event.avg_daily_use_hours = as_integer(cells[AVG_DAILY_USE_COL])

    # Avg Daily Passenger Trips
    @event.avg_daily_passenger_trips = as_integer(cells[AVG_DAILY_PASSENGER_TRIPS_COL])

    # Comments
    @event.comments = as_string(cells[COMMENTS_COL])
    
  end
  
  private
  def initialize
    super
  end
  
end