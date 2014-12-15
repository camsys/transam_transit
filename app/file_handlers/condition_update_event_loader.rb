#------------------------------------------------------------------------------
#
# ConditionUpdateEventLoader
#
# Generic class for processing condition update events
#
#------------------------------------------------------------------------------
class ConditionUpdateEventLoader < EventLoader
  
  CONDITION_RATING_COL  = 1 
  EVENT_DATE_COL        = 2 
  COMMENTS_COL          = 3
    
  def process(asset, cells)

    # Create a new ConditionUpdateEvent
    @event = asset.build_typed_event(ConditionUpdateEvent)

    # Event Date
    @event.event_date = as_date(cells[EVENT_DATE_COL])
    
    # Condition Rating
    @event.assessed_rating = as_float(cells[CONDITION_RATING_COL])
                             
    # Condition Comments
    @event.comments = as_string(cells[COMMENTS_COL])
    
  end
  
  private
  def initialize
    super
  end
  
end