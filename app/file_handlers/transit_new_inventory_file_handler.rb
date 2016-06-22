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

  CUSTOM_COLUMN_NAMES = {
    "VIN": 'Serial Number',
    "Year Built": 'Manufacture Year'
  }

  NUM_HEADER_ROWS         = 3
  SHEET_NAME              = "Updates"
  DEFAULT_SHEET_NAME      = "Defaults"

  # Perform the processing
  def process(upload)

    @num_rows_processed = 0
    @num_rows_added = 0
    @num_rows_skipped = 0
    @num_rows_replaced = 0
    @num_rows_failed = 0

    @errors = []
    @warnings = []

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

      columns = reader.read(2)
      default_row = reader.read(NUM_HEADER_ROWS)
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

          if columns[0] == "*Organization"
            org_name = cells[0].present? ? cells[0] : default_row[0]
            asset_org = Organization.find_by(name: org_name)

            asset_subtype_col = 1
            asset_tag_col = 2
          else
            asset_subtype_col = 0
            asset_tag_col = 1
          end

          if cells[asset_subtype_col].present?
            asset_classification = cells[asset_subtype_col].to_s.split('-')
          else
            asset_classification = default_row[asset_subtype_col].to_s.split('-')
          end
          type_str = asset_classification[0].strip if asset_classification[0].present?
          subtype_str = asset_classification[1].strip if asset_classification[1].present?
          # asset tags are sometimes stored as numbers
          asset_tag   = cells[asset_tag_col].to_s
          # see if the asset_tag has a ".0" which can occurr if the cell is stored as
          # a general format and the asset tag looks like a number
          if asset_tag.end_with? ".0"
            asset_tag = asset_tag.split(".0").first
          end

          Rails.logger.info "  Processing row #{row}. Subtype = '#{subtype_str}', Asset Tag = '#{asset_tag}'"
          add_processing_message(1, 'success', "Processing row[#{row}]  Subtype: '#{subtype_str}', Asset Tag: '#{asset_tag}'")

          # Find it by name or then by string search if name fails
          asset_subtype = AssetSubtype.find_by(asset_type: AssetType.find_by(name: type_str), name: subtype_str)

          # If we cant find the subtype then we need to bail on this asset
          if asset_subtype.nil?
            add_processing_message(2, 'warning', "Could not determine asset subtype from '#{subtype_str}'")
            @num_rows_failed += 1
            next
          end

          asset_exists = false
          # Check to see if this asset exists already
          asset = Asset.find_by('organization_id = ? AND asset_type_id = ? AND asset_tag = ?', asset_org.present? ? asset_org.id : organization.id, asset_subtype.asset_type.id, asset_tag)
          if asset
            if upload.force_update == false
              add_processing_message(2, 'warning', "Existing asset found with asset tag = '#{asset_tag}'. Row is being skipped.")
              @num_rows_skipped += 1
              next
            else
              # The row is being replaced.
              add_processing_message(2, 'info', "Existing asset found with asset tag = '#{asset_tag}'. Row is being replaced.")
              asset_exists = true
              # The asset needs to be typed
              asset = Asset.get_typed_asset(asset)
              # save the object key
              object_key = asset.object_key
              # remove any cached properties
              asset.destroy
              asset = Asset.new_asset(asset_subtype)
              asset.organization_id = asset_org.present? ? asset_org.id : organization.id
              asset.creator = system_user
              # restore the object key
              asset.object_key = object_key
            end
          else
            # Create an asset of the appropriate type using the factory constructor and set the org and user
            asset = Asset.new_asset(asset_subtype)
            asset.organization_id = asset_org.present? ? asset_org.id : organization.id
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

          #set ESL from policy
          policy_analyzer = asset.policy_analyzer
          asset.expected_useful_life = policy_analyzer.get_min_service_life_months
          asset.expected_useful_miles = policy_analyzer.get_min_service_life_miles

          # setup
          asset_events = []

          columns.each_with_index do |field, index|
            if index < asset_tag_col
              next
            end
            # cell present: value
            # cell present: lookup single
            # cell present: lookup multiple
            # cell not present default not present
            # cell not present default present: value
            # cell not present default present: lookup single
            # cell not present default present: lookup multiple

            # no values to set
            if cells[index].blank? and default_row[index] == 'SET DEFAULT'
              next
            end

            if field[0] == '*'
              field = field[1..field.length-1]
            end

            if is_asset_event_column(field)
              if field == "Reporting Date"
                next
              else
                input = []
                input << field

                if cells[index].present?
                  input << cells[index]
                else
                  input << default_row[index]
                end

                if cells[index+1].present?
                  input << cells[index+1]
                else
                  input << default_row[index+1]
                end

                asset_events << input
              end
            else
              if CUSTOM_COLUMN_NAMES.keys.include? field.to_sym
                field = CUSTOM_COLUMN_NAMES[field.to_sym]
              end

              field_name = field.downcase.tr(" ", "_")

              if field_name[-5..-1] == 'owner' # if owner (title owner, building owner, land owner) must look up organization
                unless field_name == 'title_owner'
                  field_name = field_name+"ship_organization"
                end
                klass = 'Organization'
              elsif field_name[-14..-1] == 'ownership_type'
                klass = 'FtaOwnershipType'
              else
                klass = field_name.singularize.classify
              end

              if cells[index].present?
                input = cells[index].to_s
              else
                input = default_row[index].to_s
                if field_name[0..3] == 'pcnt' # TEMP check for percent in default row as not formatted (not between 0 - 1)
                  input = (input.to_i / 100.0).to_f
                end
              end

              if class_exists?(klass) and field_name != 'asset_tag'
                if ["fta_mode_types", "fta_service_types", "vehicle_features", "facility_features"].include? field_name
                  val = []
                  input.split(',').each do |x|
                    if field_name == "fta_mode_types"
                      lookup = klass.constantize.find_by(code: x.strip)
                    else
                      lookup = klass.constantize.find_by(name: x.strip)
                    end
                    val << lookup if lookup.present?
                  end
                else
                  val = klass.constantize.find_by(name: input)
                end
              else
                if ['YES', 'NO'].include? input # check for boolean
                  val = input == 'YES' ? true : false
                elsif field_name[0..3] == 'pcnt' # check for percent
                  val = input.present? ? (input.to_f * 100).to_i : nil
                elsif field_name[field_name.length-4..field_name.length-1] == 'date' # check for date
                  val = Chronic.parse(input)
                else
                  val = input
                end
              end

              asset.send(field_name+'=',val)
            end

          end

          Rails.logger.info asset

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

            # add asset events
            asset_events.each do |ae|
              klass_name = ae[0].gsub(/\s+/, "") +"EventLoader"
              loader = klass_name.constantize.new
              loader.process(asset, ae[1..2])
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
                event.upload = upload
                event.save!
                add_processing_message(3, 'success', "#{ae[0]}d") #XXXX Updated
                has_new_event = true
              else
                Rails.logger.info "#{ae[0]} did not pass validation."
                event.errors.full_messages.each { |e| add_processing_message(3, 'warning', e)}
              end
            end

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

  private
    def is_asset_event_column(column_name)
      column_name[-6..-1] == "Update" or column_name == "Reporting Date"
    end


    def class_exists?(class_name)
      klass = Module.const_get(class_name)
      return klass.is_a?(Class)
    rescue NameError
      return false
    end

  # Init
  def initialize(upload)
    super
    @upload = upload
  end

end
