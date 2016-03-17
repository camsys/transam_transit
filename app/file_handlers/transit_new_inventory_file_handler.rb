#------------------------------------------------------------------------------
#
# NewInventoryFileHandler
#
# Generic class for processing new inventory from a spreadsheet.
#
# Uses the asset_subtype string to determine which type of asset to load
#
#------------------------------------------------------------------------------
class TransitNewInventoryFileHandler < AbstractFileHandler

  ASSET_SUBTYPE_COL       = 0
  ASSET_TAG_COL           = 1

  NUM_HEADER_ROWS         = 2
  SHEET_NAME              = "Updates"

  # Perform the processing
  def process(upload)

    @num_rows_processed = 0
    @num_rows_added = 0
    @num_rows_skipped = 0
    @num_rows_replaced = 0
    @num_rows_failed = 0

    # Get the pertinent info from the upload record
    file_url = upload.file.url                # Usually stored on S3
    organization = upload.organization        # Organization who owns the assets
    system_user = User.find(1)                # System user is always the first user

    add_processing_message(1, 'success', "Loading assets from '#{upload.original_filename}'")
    add_processing_message(1, 'success', "Start time = '#{Time.now}'")

    # Open the spreadsheet and start to process the assets
    begin

      reader = SpreadsheetReader.new(file_url)
      reader.open(SHEET_NAME)

      Rails.logger.info "  File Opened."
      Rails.logger.info "  Num Rows = #{reader.num_rows}, Num Cols = #{reader.num_cols}, Num Header Rows = #{NUM_HEADER_ROWS}"

      # Process each row
      count_blank_rows = 0
      first_row = NUM_HEADER_ROWS + 1
      first_row.upto(reader.last_row) do |row|
        # Read the next row from the spreadsheet
        cells = reader.read(row)
        if reader.empty_row?
          count_blank_rows += 1
          if count_blank_rows > 10
            break
          end
        else
          comments = []
          count_blank_rows = 0
          @num_rows_processed += 1

          # This is new inventory so we can get the asset subtype from the row
          subtype_str = cells[ASSET_SUBTYPE_COL].to_s
          # asset tags are sometimes stored as numbers
          asset_tag   = cells[ASSET_TAG_COL].to_s
          # see if the asset_tag has a ".0" which can occurr if the cell is stored as
          # a general format and the asset tag looks like a number
          if asset_tag.end_with? ".0"
            asset_tag = asset_tag.split(".0").first
          end

          Rails.logger.info "  Processing row #{row}. Subtype = '#{subtype_str}', Asset Tag = '#{asset_tag}'"
          add_processing_message(1, 'success', "Processing row[#{row}]  Subtype: '#{subtype_str}', Asset Tag: '#{asset_tag}'")

          # Find it by name or then by string search if name fails
          asset_subtype = AssetSubtype.find_by_name(subtype_str)

          # If we cant find the subtype then we need to bail on this asset
          if asset_subtype.nil?
            add_processing_message(2, 'warning', "Could not determine assset subtype from '#{subtype_str}'")
            @num_rows_failed += 1
            next
          end

          asset_exists = false
          # Check to see if this asset exists already
          asset = Asset.find_by('organization_id = ? AND asset_type_id = ? AND asset_tag = ?', organization.id, asset_subtype.asset_type.id, asset_tag)
          if asset
            if upload.force_update == false
              add_processing_message(2, 'warning', "Existing asset found with object key = '#{asset.object_key}'. Row is being skipped.")
              @num_rows_skipped += 1
              next
            else
              # The row is being replaced.
              add_processing_message(2, 'info', "Existing asset found with object key = '#{asset.object_key}'. Row is being replaced.")
              asset_exists = true
              # The asset needs to be typed
              asset = Asset.get_typed_asset(asset)
              # save the object key
              object_key = asset.object_key
              # remove any cached properties
              asset.destroy
              asset = Asset.new_asset(asset_subtype)
              asset.organization_id = organization.id
              asset.creator = system_user
              # restore the object key
              asset.object_key = object_key
            end
          else
            # Create an asset of the appropriate type using the factory constructor and set the org and user
            asset = Asset.new_asset(asset_subtype)
            asset.organization_id = organization.id
            asset.creator = system_user
          end

          row_errored = false

          # Asset Tag
          asset.asset_tag = asset_tag
          if asset.asset_tag.blank?
            add_processing_message(2, 'warning', "Asset tag must be defined. Row is being skipped.")
            @num_rows_skipped += 1
            next
          end

          process_loader asset, TransitGenericInventoryLoader, cells[2..3]

          if asset.type_of? :vehicle or asset.type_of? :support_vehicle
            process_loader asset, TransitVehicleInventoryLoader, cells[4..11]
          elsif asset.type_of? :transit_facility or asset.type_of? :support_facility
            process_loader asset, TransitFacilityInventoryLoader, cells[4..15]
          elsif asset.type_of? :rail_car or asset.type_of? :locomotive
            process_loader asset, TransitRailInventoryLoader, cells[4..9]
          end

          # Check for any validation errors
          if ! asset.valid?
            row_errored = true
            Rails.logger.info "Asset did not pass validation."
            asset.errors.full_messages.each { |e| add_processing_message(2, 'warning', e)}
            puts asset.errors.inspect
          end

          # If there are errors then we abort this row
          if row_errored
            @num_rows_failed += 1
            add_processing_message(2, 'error', "Too many errors. Row cannot be saved.")
            next
          end

          if asset.save
            if asset_exists
              add_processing_message(2, 'success', "Asset updated.")
              @num_rows_replaced += 1
            else
              add_processing_message(2, 'success', "New asset created.")
              @num_rows_added += 1
            end
          end

          # Fire update events for the asset. Make sure the asset gets the SOGR updates processed.
          if asset
            Delayed::Job.enqueue AssetUpdateJob.new(asset.object_key), :priority => 10
          else
            Rails.logger.warn "Asset is not defined on row #{row}"
          end
        end
      end

      @new_status = FileStatusType.find_by_name("Complete")
    rescue => e
      Rails.logger.warn "Exception caught: #{e}"
      @new_status = FileStatusType.find_by_name("Errored")
      puts e.message
      puts e.backtrace.join("\n")
      raise e
    ensure
      reader.close unless reader.nil?
    end

    add_processing_message(1, 'success', "Processing Completed at  = '#{Time.now}'")

  end

  def process_loader asset, klass, cells
    loader = klass.new

    # Populate the characteristics from the row
    loader.process(asset, cells)
    if loader.errors?
      row_errored = true
      loader.errors.each { |e| add_processing_message(2, 'warning', e)}
    end
    if loader.warnings?
      loader.warnings.each { |e| add_processing_message(2, 'info', e)}
    end

  end

  def record_event asset, event_message, klass, cells

    loader = klass.new
    loader.process(asset, cells)
    if loader.errors?
      row_errored = true
      loader.errors.each { |e| add_processing_message(3, 'warning', e)}
    end
    if loader.warnings?
      loader.warnings.each { |e| add_processing_message(3, 'info', e)}
    end
    # Check for any validation errors
    event = loader.event
    if event.valid?
      event.save
      add_processing_message(3, 'success', "#{event_message} added.")
    else
      Rails.logger.info "#{event_message} did not pass validation."
      event.errors.full_messages.each { |e| add_processing_message(3, 'warning', e)}
    end

  end

  # Init
  def initialize(upload)
    super
    @upload = upload
  end

end
