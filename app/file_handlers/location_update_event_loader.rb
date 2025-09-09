#------------------------------------------------------------------------------
#
# LocationUpdateEventLoader
#
# Generic class for processing location update events
#
#------------------------------------------------------------------------------
class LocationUpdateEventLoader < EventLoader

  LOCATION_COL   = 0
  EVENT_DATE_COL = 1

  def process(asset, cells)

    # Create a new LocationUpdateEvent
    @event = asset.build_typed_event(LocationUpdateEvent)

    # Event Date
    @event.event_date = as_date(cells[EVENT_DATE_COL])
    
    # Location
    val = as_string(cells[LOCATION_COL])&.split(":")[1]&.strip
    matching_facility = Facility.find_by(object_key: val)
    unless matching_facility.nil?
      @event.parent = matching_facility.transam_asset
    end

    if @event.parent.nil?
      @warnings << "Location not set."
    end

  end

  private
  def initialize
    super
  end

end
