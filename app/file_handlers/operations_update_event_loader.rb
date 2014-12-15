#------------------------------------------------------------------------------
#
# OperationsUpdateEventLoader
#
# Generic class for processing operations update events
#
#------------------------------------------------------------------------------
class OperationsUpdateEventLoader < EventLoader
  
  AVG_COST_PER_MILE_COL           = 2
  AVG_MILES_PER_GALLON_COL        = 3 
  ANNUAL_MAINTENANCE_COST_COL     = 4
  ANNUAL_INSURANCE_COST_COL       = 5 
  EVENT_DATE_COL                  = 6 
  COMMENTS_COL                    = 7
    
  def process(asset, cells)

    # Create a new OperationsUpdateEvent
    @event = asset.build_typed_event(OperationsUpdateEvent)

    # Event Date
    @event.event_date = as_date(cells[EVENT_DATE_COL])
            
    # Average Cost Per Mile
    @event.avg_cost_per_mile = as_float(cells[AVG_COST_PER_MILE_COL])

    # Average Miles Per Gallon
    @event.avg_miles_per_gallon = as_float(cells[AVG_MILES_PER_GALLON_COL])
          
    # Annual Maintenance Cost
    @event.annual_maintenance_cost = as_integer(cells[ANNUAL_MAINTENANCE_COST_COL])

    # Annual Insurance Cost
    @event.annual_insurance_cost = as_integer(cells[ANNUAL_INSURANCE_COST_COL])
                   
    # Condition Comments
    @event.comments = as_string(cells[COMMENTS_COL])
    
  end
  
  private
  def initialize
    super
  end
  
end