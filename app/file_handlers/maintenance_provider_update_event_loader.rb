#------------------------------------------------------------------------------
#
# MaintenanceProviderUpdateEventLoader
#
# Generic class for processing condition update events
#
#------------------------------------------------------------------------------
class MaintenanceProviderUpdateEventLoader < EventLoader
  
  MAINTENANCE_PROVIDER_TYPE_COL   = 0
  EVENT_DATE_COL                  = 6 
  COMMENTS_COL                    = 7
    
  def process(asset, cells)

    # Create a new MileageUpdateEvent
    @event = asset.build_typed_event(MaintenanceProviderUpdateEvent)

    # Event Date
    @event.event_date = as_date(cells[EVENT_DATE_COL])

    # Condition Comments
    #@event.comments = as_string(cells[COMMENTS_COL])
    
    # Maintenance Provider Type
    val = as_string(cells[MAINTENANCE_PROVIDER_TYPE_COL])
    @event.maintenance_provider_type = MaintenanceProviderType.search(val)
    if @event.maintenance_provider_type.nil?
      @event.maintenance_provider_type = MaintenanceProviderType.find_by_name("Unknown")
      @warnings << "Maintenance Provider Type not set."
    end
    
  end
  
  private
  def initialize
    super
  end
  
end