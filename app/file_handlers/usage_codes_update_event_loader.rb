#------------------------------------------------------------------------------
#
# UsageCodesUpdateEventLoader
#
# Generic class for processing usage update events
#
#------------------------------------------------------------------------------
class UsageCodesUpdateEventLoader < EventLoader
  
  VEHICLE_USAGE_CODES_COL       = 3 
  EVENT_DATE_COL                = 4 
  COMMENTS_COL                  = 5
    
  def process(asset, cells)

    # Create a new UsageUpdateEvent
    @event = asset.build_typed_event(UsageCodesUpdateEvent)

    # Event Date
    @event.event_date = as_date(cells[EVENT_DATE_COL])

    # Comments
    #@event.comments = as_string(cells[COMMENTS_COL])

    # Vehicle Use Codes                      
    vals = as_string(cells[VEHICLE_USAGE_CODES_COL])  
    if ! vals.blank?
      vals.split(",").each do |val|
        val.strip!    
        x = VehicleUsageCode.search(val)   
        if x.nil?
          @warnings << "Vehicle Usage Code '#{val}' not recognized. Skipping."
        else
          @event.vehicle_usage_codes << x          
        end                    
      end
    end
    
  end
  
  private
  def initialize
    super
  end
  
end