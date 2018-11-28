#------------------------------------------------------------------------------
#
# RehabilitationUpdateEventLoader
#
# Generic class for scheduling rehabilitation
#
#------------------------------------------------------------------------------
class RebuildRehabilitationUpdateEventLoader < EventLoader

  TOTAL_COST_COL  = 0
  E_U_L_MONTHS    = 1
  E_U_L_MILES     = 2
  EVENT_DATE_COL  = 3
    
  def process(asset, cells)

    # Create a new ScheduleReplacementUpdateEvent
    @event = asset.build_typed_event(RehabilitationUpdateEvent)

    # scheduled replacement year
    @event.total_cost = as_integer(cells[TOTAL_COST_COL])
    @event.extended_useful_life_months = as_integer(cells[E_U_L_MONTHS])
    @event.extended_useful_life_miles = as_integer(cells[E_U_L_MILES])
    @event.event_date = as_date(cells[EVENT_DATE_COL])
  end
  
  private
  def initialize
    super
  end
  
end