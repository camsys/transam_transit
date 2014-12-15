#------------------------------------------------------------------------------
#
# ReplacementUpdateEventLoader
#
# Generic class for processing mileage update events
#
#------------------------------------------------------------------------------
class ReplacementUpdateEventLoader < EventLoader
  
  REPLACEMENT_YEAR_COL  = 0
  REBUILD_YEAR_COL      = 1 
  COMMENTS_COL          = 2
    
  def process(asset, cells)

    # Create a new ScheduleReplacementUpdateEvent
    @event = asset.build_typed_event(ScheduleReplacementUpdateEvent)

    # Event Date
    @event.event_date = Date.today
    
    # scheduled replacement year
    @event.replacement_year = as_year(cells[REPLACEMENT_YEAR_COL])

    # scheduled rebuild year
    @event.rebuild_year = as_year(cells[REBUILD_YEAR_COL])

    # Condition Comments
    @event.comments = as_string(cells[COMMENTS_COL])
    
  end
  
  private
  def initialize
    super
  end
  
end