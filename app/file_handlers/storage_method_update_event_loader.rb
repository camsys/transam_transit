#------------------------------------------------------------------------------
#
# OperationsUpdateEventLoader
#
# Generic class for processing operations update events
#
#------------------------------------------------------------------------------
class StorageMethodUpdateEventLoader < EventLoader
  
  VEHICLE_STORAGE_METHOD_TYPE_COL = 1 
  EVENT_DATE_COL                  = 6 
  COMMENTS_COL                    = 7
    
  def process(asset, cells)

    # Create a new OperationsUpdateEvent
    @event = asset.build_typed_event(StorageMethodUpdateEvent)

    # Event Date
    @event.event_date = as_date(cells[EVENT_DATE_COL])

    # Condition Comments
    #@event.comments = as_string(cells[COMMENTS_COL])

    # Vehicle Storage Method Type -- This is coded as Indoors/Outdoors/Both
    val = as_string(cells[VEHICLE_STORAGE_METHOD_TYPE_COL])
    if val == 'Both'
      val == 'Indoor/Outdoor' 
    end
    @event.vehicle_storage_method_type = VehicleStorageMethodType.search(val)
    if @event.vehicle_storage_method_type.nil?
      @event.vehicle_storage_method_type = VehicleStorageMethodType.find_by_name("Unknown")
      @warnings << "Vehicle Storage Method Type not set."
    end
                
  end
  
  private
  def initialize
    super
  end
  
end