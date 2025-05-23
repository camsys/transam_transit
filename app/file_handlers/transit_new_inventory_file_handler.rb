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
      "Name": 'Description',
      "VIN": 'Serial Number',
      "Year Built": 'Manufacture Year',
      "ADA Accessible": 'ADA Accessible',
      "ADA Compliant": 'ADA Accessible Ramp',
      "Parent Asset Tag": 'Parent Id',
      "Private Mode": 'FTA Private Mode Type',
      "Primary Mode": 'Primary FTA Mode Type ID',
      "Secondary Modes": 'Secondary FTA Mode Type IDs',
      "Supports Another Mode": 'Secondary FTA Mode Type ID',
      "FTA Service Type": 'Primary FTA Service Type ID',
      "Supports Another FTA Service Type": 'Secondary FTA Service Type ID'
  }

  # ADA
  # Vehicle - Accessible, lift
  # Support Vehicle - NONE
  # TransitFacility - Compliant, ramp
  # SupportFacility - Accessible, ramp
  # RailCar -  both by name
  # Locomotive - NONE

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

    @template_definer = nil

    # Get the pertinent info from the upload record
    file_url = upload.file.url                # Usually stored on S3
    organization = upload.organization        # Organization who owns the assets
    system_user = User.find(1)                # System user is always the first user

    add_processing_message(1, 'success', "Loading assets from '#{upload.original_filename}'")
    add_processing_message(1, 'success', "Start time = '#{Time.now}'")

    # Open the spreadsheet and start to process the assets
    begin

      reader = SpreadsheetReader.new(file_url)
      sheets = reader.find_sheets

      if sheets.include? 'Revenue Vehicles'
        reader.open('Revenue Vehicles')
        @template_definer = TransitRevenueVehicleTemplateDefiner.new
      elsif sheets.include? 'Service Vehicles'
        reader.open('Service Vehicles')
        @template_definer = TransitServiceVehicleTemplateDefiner.new
      elsif sheets.include? 'Capital Equipment'
        reader.open('Capital Equipment')
        @template_definer = TransitCapitalEquipmentTemplateDefiner.new
      elsif sheets.include? 'Facilities'
        reader.open('Facilities')
        @template_definer = TransitFacilityTemplateDefiner.new
      elsif sheets.include? 'Facility Components'
        reader.open('Facility Components')
        @template_definer = TransitFacilitySubComponentTemplateDefiner.new
      elsif sheets.include? 'Infrastructure - Guideways'
        reader.open('Infrastructure - Guideways')
        @template_definer = TransitInfrastructureGuidewayTemplateDefiner.new
      elsif sheets.include? 'Infrastructure - Track'
        reader.open('Infrastructure - Track')
        @template_definer = TransitInfrastructureTrackTemplateDefiner.new
      elsif sheets.include? 'Infrastructure - Power & Signal'
        reader.open('Infrastructure - Power & Signal')
        @template_definer = TransitInfrastructurePowerSignalTemplateDefiner.new
      elsif sheets.include? 'Infra - Guideway Components'
        reader.open('Infra - Guideway Components')
        @template_definer = TransitInfrastructureGuidewaySubcomponentTemplateDefiner.new
      elsif sheets.include? 'Infra - Track Components'
        reader.open('Infra - Track Components')
        @template_definer = TransitInfrastructureTrackSubcomponentTemplateDefiner.new
      elsif sheets.include? 'Infra - Power.Signal Components'
        reader.open('Infra - Power.Signal Components')
        @template_definer = TransitInfrastructurePowerSignalSubcomponentTemplateDefiner.new
      else
        reader.open(SHEET_NAME)
      end

      Rails.logger.info "  File Opened."
      Rails.logger.info "  Num Rows = #{reader.num_rows}, Num Cols = #{reader.num_cols}, Num Header Rows = #{NUM_HEADER_ROWS}"

      # Process each row
      count_blank_rows = 0

      columns = reader.read(2)
      # default_row = reader.read(NUM_HEADER_ROWS)
      first_row = 3
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


          if columns[0] == "Agency" || columns[0] == "Organization"
            org_name = cells[0].to_s.split(' : ').last
            asset_org = Organization.find_by(name: org_name)
          else
            asset_subtype_col = 0
            asset_tag_col = 1
          end

          is_component = false

          if @template_definer.class == TransitRevenueVehicleTemplateDefiner
            # proto_asset = RevenueVehicle.new
            proto_asset = @template_definer.set_initial_asset(cells)
          elsif @template_definer.class == TransitServiceVehicleTemplateDefiner
            proto_asset = @template_definer.set_initial_asset(cells)
          elsif @template_definer.class == TransitCapitalEquipmentTemplateDefiner
            proto_asset = @template_definer.set_initial_asset(cells)
          elsif @template_definer.class == TransitFacilityTemplateDefiner
            proto_asset = @template_definer.set_initial_asset(cells)
          elsif @template_definer.class == TransitFacilitySubComponentTemplateDefiner
            is_component = true
            proto_asset = @template_definer.set_initial_asset(cells)
          elsif @template_definer.class == TransitInfrastructureGuidewayTemplateDefiner
            proto_asset = @template_definer.set_initial_asset(cells)
          elsif @template_definer.class == TransitInfrastructureTrackTemplateDefiner
            proto_asset = @template_definer.set_initial_asset(cells)
          elsif @template_definer.class == TransitInfrastructurePowerSignalTemplateDefiner
            proto_asset = @template_definer.set_initial_asset(cells)
          elsif @template_definer.class == TransitInfrastructurePowerSignalSubcomponentTemplateDefiner
            is_component = true
            infrastructure_component = true
            proto_asset = @template_definer.set_initial_asset(cells)
          elsif @template_definer.class == TransitInfrastructureTrackSubcomponentTemplateDefiner
            is_component = true
            infrastructure_component = true
            proto_asset = @template_definer.set_initial_asset(cells)
          elsif @template_definer.class == TransitInfrastructureGuidewaySubcomponentTemplateDefiner
            is_component = true
            infrastructure_component = true
            proto_asset = @template_definer.set_initial_asset(cells)
          end

          asset_tag_col = @template_definer.asset_tag_column_number

          unless is_component
            asset_subtype_col = @template_definer.subtype_column_number

            if cells[asset_subtype_col].present?
              asset_classification = cells[asset_subtype_col]
            else
              add_processing_message(2, 'danger', "Subtype column for row[#{row}] cannot be blank.")
              @num_rows_failed += 1
              next
            end
            # type_str = asset_classification[1].strip if asset_classification[1].present?
            subtype_str = asset_classification.strip if asset_classification.present?
          end

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
          unless is_component
            asset_subtype = AssetSubtype.find_by(name: subtype_str)

            # If we cant find the subtype then we need to bail on this asset
            if asset_subtype.nil?
              add_processing_message(2, 'danger', "Could not determine asset subtype from '#{subtype_str}'")
              @num_rows_failed += 1
              next
            end
          end

          # If we dont have an org then we need to bail on this asset
          if asset_org.nil? && organization.nil?
            add_processing_message(2, 'danger', "Could not determine organization'")
            @num_rows_failed += 1
            next
          end

          asset_exists = false
          # Check to see if this asset exists already
          asset = TransamAsset.find_by('organization_id = ? AND asset_tag = ?', asset_org.present? ? asset_org.id : organization.id, asset_tag)
          if asset
            if upload.force_update == false
              add_processing_message(2, 'danger', "Existing asset found with asset tag = '#{asset_tag}'. Row is being skipped.")
              @num_rows_skipped += 1
              next
            else
              # The row is being replaced.
              add_processing_message(2, 'info', "Existing asset found with asset tag = '#{asset_tag}'. Row is being replaced.")
              asset_exists = true

              asset = TransamAsset.get_typed_asset(asset)

              # save the object key
              object_key = asset.object_key
              # remove any cached properties
              asset.destroy
            end
          end

          # Create an asset of the appropriate type using the factory constructor and set the org and user
          asset = proto_asset
          asset.organization_id = asset_org.present? ? asset_org.id : organization.id
          # asset.creator = system_user
          asset.object_key = object_key if object_key.present?

          row_errored = false

          # Asset Tag
          asset.asset_tag = asset_tag
          if asset.asset_tag.blank?
            add_processing_message(2, 'danger', "Asset tag must be defined.")
            @num_rows_failed += 1
            next
          end

          #set ESL from policy
          # policy_analyzer = asset.policy_analyzer
          # asset.expected_useful_life = policy_analyzer.get_min_service_life_months
          # asset.expected_useful_miles = policy_analyzer.get_min_service_life_miles

          # setup
          asset_events = []

          unless @template_definer.nil?
            @template_definer.set_columns(asset, cells, columns)

            messages = @template_definer.get_messages_to_process

            messages.each {|m|
              add_processing_message(m[0], m[1], m[2])
              if m[1] == 'danger'
                row_errored = true
              end
            }

            @template_definer.clear_messages_to_process

          else
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
                if ["Reporting Date", "Sales Proceeds","Mileage At Disposition"].include? field
                  next
                else
                  input = []
                  input << field

                  if field == 'Disposition Update'
                    event_info_cols = 4
                  else
                    event_info_cols = 2
                  end
                  (0..event_info_cols-1).each do |i|
                    if cells[index+i].present?
                      input << cells[index+i]
                    else
                      input << default_row[index+i]
                    end
                  end

                  asset_events << input
                end
              else
                if CUSTOM_COLUMN_NAMES.keys.include? field.to_sym
                  field = CUSTOM_COLUMN_NAMES[field.to_sym]
                  if field == 'ADA Accessible'
                    if asset_subtype.asset_type.class_name == 'Vehicle'
                      field = field + ' Lift'
                    elsif asset_subtype.asset_type.class_name == 'SupportFacility'
                      field =  field + ' Ramp'
                    end
                  end
                end

                # deal with label of FTA Support Vehicle Type
                if field == "FTA Vehicle Type" && (asset.type_of? :support_vehicle)
                  field = "FTA Support Vehicle Type"
                end

                field_name = field.downcase.tr(" ", "_")

                if field_name[-5..-1] == 'owner' # if owner (title holder, building owner, land owner) must look up organization
                  unless field_name == 'title_holder'
                    field_name = field_name+"ship_organization"
                  end
                  klass = 'Organization'
                elsif field_name[-14..-1] == 'ownership_type' && !(field_name.include? 'other')
                  klass = 'FtaOwnershipType'
                elsif (field_name.include? 'fta_mode_type')
                  klass = 'FtaModeType'
                elsif (field_name.include? 'fta_service_type')
                  klass = 'FtaServiceType'
                else
                  klass = field_name.singularize.classify
                end

                if cells[index].present?
                  input = cells[index].to_s
                else
                  input = default_row[index].to_s
                end

                if class_exists?(klass) and field_name != 'asset_tag'
                  if ["secondary_fta_mode_type_ids","vehicle_features", "facility_features"].include? field_name
                    val = []
                    input.split(',').each do |x|
                      lookup = klass.constantize.find_by(name: x.strip) || klass.constantize.find_by(code: x.strip)
                      if field_name == 'secondary_fta_mode_type_ids'
                        val << lookup.id if lookup.present?
                      else
                        val << lookup if lookup.present?
                      end
                    end
                  else
                    if field_name == "manufacturer"
                      val = klass.constantize.where(name: input, filter: asset_subtype.asset_type.class_name).first
                    elsif field_name == "dual_fuel_type"
                      fuel_types = input.split('-')
                      val =  klass.constantize.find_by(primary_fuel_type_id: FuelType.find_by(name: fuel_types[0]).id, secondary_fuel_type_id: FuelType.find_by(name: fuel_types[1]).id)
                    elsif (field_name.include? 'primary') || (field_name.include? 'secondary')
                      val = klass.constantize.find_by(name: input).id
                    elsif field_name == 'vendor'
                      val = klass.constantize.find_by(name: input, organization_id: asset.organization_id)
                    else
                      val = klass.constantize.find_by(name: input)
                    end
                  end
                else
                  if ['YES', 'NO'].include? input.to_s.upcase # check for boolean
                    val = input.to_s.upcase == 'YES' ? 1 : 0
                  elsif field_name[0..3] == 'pcnt' # check for percent
                    val = input.present? ? (input.to_f * 100).to_i : nil
                  elsif field_name[field_name.length-4..field_name.length-1] == 'date' # check for date
                    val = Chronic.parse(input)
                  elsif field_name == 'parent_id'
                    val = Asset.find_by(organization_id: asset.organization_id, asset_tag: input).id
                  else
                    val = input
                  end
                end

                if val.present?
                  if Asset.columns_hash[field_name].try(:type) == :integer
                    val = val.to_i
                  end
                  asset.send(field_name+'=',val)
                end

              end

            end
          end

          # Check for any validation errors
          if ! asset.valid?
            row_errored = true
            Rails.logger.info "Asset did not pass validation."
            asset.errors.full_messages.each { |e| add_processing_message(2, 'danger', e)}
            puts asset.errors.inspect
          end

          # If there are errors then we abort this row
          if row_errored
            @num_rows_failed += 1
            add_processing_message(2, 'error', "Too many errors. Row cannot be saved.")
            next
          end

          # update reference so asset is linked to upload
          asset.upload = upload
          if @template_definer.class == TransitFacilityTemplateDefiner
            asset.creator = upload&.user
          end

          if asset.save

            if @template_definer.class == TransitInfrastructurePowerSignalSubcomponentTemplateDefiner ||
               @template_definer.class == TransitInfrastructureTrackSubcomponentTemplateDefiner ||
               @template_definer.class == TransitInfrastructureGuidewaySubcomponentTemplateDefiner

              asset_parent = asset.parent.very_specific

              asset_parent.infrastructure_components << asset
              asset_parent.save
            end


            # add asset events
            unless @template_definer.nil?
              @template_definer.set_events(asset, cells, columns, upload)
              messages = @template_definer.get_messages_to_process

              messages.each {|m|
                add_processing_message(m[0], m[1], m[2])
              }
            else
              asset_events.each do |ae|
                update_name = ae[0].gsub(/\s+/, "")
                klass_name = update_name+"EventLoader"
                loader = klass_name.constantize.new
                loader.process(asset, ae[1..2])
                if loader.errors?
                  row_errored = true
                  loader.errors.each { |e| add_processing_message(3, 'danger', e)}
                end
                if loader.warnings?
                  loader.warnings.each { |e| add_processing_message(3, 'warning', e)}
                end

                # Check for any validation errors
                event = loader.event
                if event.valid?
                  event.upload = upload
                  event.creator = upload.user
                  event.updater = upload.user
                  event.save!
                  add_processing_message(3, 'success', "#{ae[0]}d") #XXXX Updated
                  has_new_event = true

                  # if update_name == 'DispositionUpdate'
                  #   Delayed::Job.enqueue AssetDispositionUpdateJob.new(asset.object_key), :priority => 10
                  # end
                else
                  Rails.logger.info "#{ae[0]} did not pass validation."
                  event.errors.full_messages.each { |e| add_processing_message(3, 'danger', e)}
                end
              end
            end

            # all assets must have one service status update
            if asset.service_status_updates.count == 0 && !infrastructure_component
              asset.destroy
              @num_rows_failed += 1
              add_processing_message(2, 'error', "Asset doesn't have service status update.")
            else
              if asset_exists
                add_processing_message(2, 'success', "Asset updated.")
                @num_rows_replaced += 1
              else
                add_processing_message(2, 'success', "New asset created.")
                @num_rows_added += 1
              end
            end

            #Delayed::Job.enqueue AssetUpdateJob.new(asset.object_key), :priority => 10
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
    column_name[-6..-1] == "Update" or (["Reporting Date", "Sales Proceeds","Mileage At Disposition"].include? column_name)
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
