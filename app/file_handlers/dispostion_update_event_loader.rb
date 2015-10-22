#------------------------------------------------------------------------------
#
# DispositionUpdateEventLoader
#
# Generic class for processing usage update events
#
#------------------------------------------------------------------------------
class DispositionUpdateEventLoader < EventLoader


  def process(asset, cells)

    include_mileage = (asset.asset_type.class_name == "Vehicle" || asset.asset_type.class_name == "SupportVehicle")

    if include_mileage
        columns = {
                    # Disposition Update Columns
                    'Scheduled Year' => 6,
                    'Disposition Date' => 7,
                    'Disposition Type' => 8,
                    'Sales Proceeds' => 9,
                    'Mileage at Disposition' => 10,
                    # Comment
                    'Comments' => 11 }
      else
        columns = {
                    # Disposition Update Columns
                    'Scheduled Year' => 6,
                    'Disposition Date' => 7,
                    'Disposition Type' => 8,
                    'Sales Proceeds' => 9,
                    # Comment
                    'Comments' => 10 }
      end

    # Create a new DispositionUpdateEvent
    @event = asset.build_typed_event(DispositionUpdateEvent)

    # Event Date
    @event.event_date = as_date(cells[columns['Disposition Date']])

    # Disposition Type
    val = as_string(cells[columns['Disposition Type']])
    @event.disposition_type = DispositionType.search(val)
    if @event.disposition_type.nil?
      @errors << "Dispositon Type not found or missing. Type = #{val}."
    end

    # Sales Proceeds
    @event.sales_proceeds = as_integer(cells[columns['Sales Proceeds']])

    # Mileage at disposition
    @event.mileage_at_disposition = as_integer(cells[columns['Mileage at Disposition']]) if columns['Mileage at Disposition'].present?

    # Comments
    @event.comments = as_string(cells[columns["Comments"]])

  end

  private

  def initialize
    super
  end

end
