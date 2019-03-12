class TransitInfrastructureGuidewayTemplateDefiner
  require 'rubyXL'

  SHEET_NAME = InventoryUpdatesFileHandler::SHEET_NAME

  def subtype_column_number
    @subtype_column_number[1]
  end
  def asset_tag_column_number
    @asset_id_column_number[1]
  end

  def setup_instructions()
    instructions = [
        '• Infrastructure - Guideway tab contains a table where users should enter asset data. Users should enter 1 linear track segment per row and 1 attribute per column',
        '• Green Cells are required in the system',
        '• White Cells are recommended but not required',
        '• Grey Cells are only applicable if the user selects Other or under other unique circumstances (some may be required if "Other" is selected)',
        # '• Asset IDs and Row Names are frozen to assist in scrolling through the table',
        '• It is recommended that guideway records be entered for each unique Subtype of linear segment of guideway. Each individual Subtype segment can be broken down further by Segment Type, if desired.',
        "• The List of Fields tab displays a table of all the attributes sorted by color (required status)",
        '• Several Identification & Classification fields are configurable by organization and must be updated prior to conducting an initial Infrastructure - Guideway bulk upload. These fields include: Main Line / Division; and Branch / Subdivision.'
    ]
  end

  def setup_lookup_sheet(wrkb, lookups)
    @lookups = lookups
  end

  def add_columns(sheet, template, org, fta_asset_class, earliest_date)

    dark_green_fill = '6BB14A'
    light_green_fill = '6BB14A'
    grey_fill = 'DBDBDB'
    white_fill = '000000'

    # TODO I almost want to make a class that is just all of these column definitions. Then the builder classes are just a list of calls to make up what is needed
    template.add_column(sheet, 'Organization', 'Identification & Classification', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('organizations')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Organization',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Asset / Segment ID', 'Identification & Classification', {name: 'required_string'})

    template.add_column(sheet, 'External ID', 'Identification & Classification', {name: 'recommended_string'})

    template.add_column(sheet, 'Description', 'Identification & Classification', {name: 'recommended_string'})

    template.add_column(sheet, 'Location', 'Identification & Classification', {name: 'recommended_string'})

    template.add_column(sheet, 'From Line', 'Identification & Classification', {name: 'required_string'})

    template.add_column(sheet, 'From', 'Identification & Classification', {name: 'required_string'})

    template.add_column(sheet, 'To Line', 'Identification & Classification', {name: 'required_string'})

    template.add_column(sheet, 'To', 'Identification & Classification', {name: 'required_string'})

    template.add_column(sheet, 'Unit', 'Identification & Classification',  {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('track_max_perm_units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Units',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Segment Unit', 'Identification & Classification',  {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('infrastructure_segment_unit')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Segment Unit',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'From (Location Name)', 'Identification & Classification', {name: 'recommended_string'})

    template.add_column(sheet, 'To (Location Name)', 'Identification & Classification', {name: 'recommended_string'})

    template.add_column(sheet, 'Class', 'Identification & Classification', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('fta_asset_classes')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Class',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Type', 'Identification & Classification', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('guideway_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Type',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Subtype', 'Identification & Classification', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('asset_subtypes')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Subtype',
        :prompt => 'Only values in the list are allowed'})

    # segment
    template.add_column(sheet, 'Segment Type', 'Identification & Classification', {name: 'required_string'}, {
            :type => :list,
            :formula1 => "lists!#{template.get_lookup_cells('segment_type')}",
            :showErrorMessage => true,
            :errorTitle => 'Wrong input',
            :error => 'Select a value from the list',
            :errorStyle => :stop,
            :showInputMessage => true,
            :promptTitle => 'Asset Subtype',
            :prompt => 'Only values in the list are allowed'})

    # mainline
    template.add_column(sheet, 'Main Line / Division', 'Identification & Classification', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('mainline')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Asset Subtype',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Branch Subdivision', 'Identification & Classification', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('branch_subdivisions')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Asset Subtype',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Number of Tracks', 'Identification & Classification', {name: 'last_recommended_integer'}, {
        :type => :whole,
        :operator => :greaterThan,
        :formula1 => '0',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be > 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Number of Tracks',
        :prompt => 'Only values greater than 0'}, 'default_values', [1])

    template.add_column(sheet, 'Bridge Type', 'Characteristics (bridges only)', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('bridge_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Asset Subtype',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Number of Spans', 'Characteristics (bridges only)', {name: 'last_recommended_integer'}, {
        :type => :whole,
        :operator => :greaterThan,
        :formula1 => '0',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be > 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Number of Spans',
        :prompt => 'Only values greater than 0'}, 'default_values', [1])

    template.add_column(sheet, 'Number of Decks', 'Characteristics (Bridges and tunnels only)', {name: 'recommended_integer'}, {
        :type => :whole,
        :operator => :greaterThan,
        :formula1 => '0',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be > 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Number of Decks',
        :prompt => 'Only values greater than 0'}, 'default_values', [1])

    template.add_column(sheet, 'Crossing', 'Characteristics (Bridges and tunnels only)', {name: 'last_recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('guideway_crossing')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Asset Subtype',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Length', 'Geometry', {name: 'recommended_integer'}, {
        :type => :whole,
        :operator => :greaterThan,
        :formula1 => '0',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be > 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Length',
        :prompt => 'Only values greater than 0'}, 'default_values', [1])

    template.add_column(sheet, 'Length Unit', 'Geometry',  {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('gauge_units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Length Units',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Height', 'Geometry', {name: 'recommended_integer'}, {
        :type => :whole,
        :operator => :greaterThan,
        :formula1 => '0',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be > 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Height',
        :prompt => 'Only values greater than 0'}, 'default_values', [1])

    template.add_column(sheet, 'Height Unit', 'Geometry',  {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('gauge_units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Length Units',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Width', 'Geometry', {name: 'recommended_integer'}, {
        :type => :whole,
        :operator => :greaterThan,
        :formula1 => '0',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be > 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Length',
        :prompt => 'Only values greater than 0'}, 'default_values', [1])

    template.add_column(sheet, 'Width Unit', 'Geometry',  {name: 'last_required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('gauge_units')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Width Units',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Direct Capital Responsibility', 'Funding', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('booleans')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Direct Capital Responsibility',
        :prompt => 'Only values in the list are allowed'}, 'default_values', ['NO'])

    template.add_column(sheet, '% Capital Responsibility', 'Funding', {name: 'required_pcnt'}, {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => '0',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be integer >= 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => '% Capital Responsibility',
        :prompt => 'Only integers greater than or equal to 0'})

    template.add_column(sheet, 'Organization With Shared Capitol Responsibility', 'Funding', {name: 'last_required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('all_organizations')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Organization',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Primary Mode', 'Operations', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('fta_mode_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Primary Mode',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Service Type (Primary Mode)', 'Operations', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('fta_service_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Service Type (Primary Mode)',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Nearest City', 'Operations', {name: 'recommended_string'})

    template.add_column(sheet, 'State', 'Operations', {name: 'last_recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('states')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Type',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Land Owner', 'Registration and Title', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('all_organizations')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Organization',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, "Land Owner (Other)", 'Registration and Title', {name: 'other_string'})

    template.add_column(sheet, 'Infrastructure Owner', 'Registration and Title', {name: 'recommended_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('all_organizations')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Organization',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, "Infrastructure Owner (Other)", 'Registration and Title', {name: 'last_other_string'})

    template.add_column(sheet, 'Condition', 'Initial Event Data', {name: 'recommended_integer'}, {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => '0',
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Must be integer >= 0',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Condition',
        :prompt => 'Only integers greater than or equal to 0'})

    template.add_column(sheet, 'Date of Last Condition Reading', 'Initial Event Data', {name: 'recommended_date'}, {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => earliest_date.strftime("%-m/%d/%Y"),
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}",
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Condition Reading Date',
        :prompt => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}"}, 'default_values', [Date.today.strftime('%m/%d/%Y')])

    template.add_column(sheet, 'Service Status', 'Initial Event Data', {name: 'required_string'}, {
        :type => :list,
        :formula1 => "lists!#{template.get_lookup_cells('service_status_types')}",
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => 'Select a value from the list',
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Service Status',
        :prompt => 'Only values in the list are allowed'})

    template.add_column(sheet, 'Date of Last Service Status', 'Initial Event Data', {name: 'last_required_date'}, {
        :type => :whole,
        :operator => :greaterThanOrEqual,
        :formula1 => earliest_date.strftime("%-m/%d/%Y"),
        :showErrorMessage => true,
        :errorTitle => 'Wrong input',
        :error => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}",
        :errorStyle => :stop,
        :showInputMessage => true,
        :promptTitle => 'Service Status Date',
        :prompt => "Date must be after #{earliest_date.strftime("%-m/%d/%Y")}"}, 'default_values', [Date.today.strftime('%m/%d/%Y')])

    post_process(sheet)
  end


  def post_process(sheet)
    sheet.sheet_view.pane do |pane|
      pane.top_left_cell = RubyXL::Reference.ind2ref(3,10)
      pane.state = :frozen
      pane.y_split = 2
      pane.x_split = 9
      pane.active_pane = :bottom_right
    end
  end

  def set_columns(asset, cells, columns)
    @add_processing_message = []

    organization = cells[@agency_column_number[1]].to_s.split(' : ').last
    asset.organization = Organization.find_by(name: organization)

    asset.asset_tag = cells[@asset_id_column_number[1]]
    asset.external_id = cells[@external_id_column_number[1]]
    asset.description = cells[@description_column_number[1]]
    asset.location_name = cells[@location_column_number[1]]
    asset.from_line = cells[@line_from_line_column_number[1]]
    asset.from_segment = cells[@line_from_from_column_number[1]]
    asset.to_line = cells[@line_to_line_column_number[1]]
    asset.to_segment = cells[@line_to_to_column_number[1]]
    asset.infrastructure_segment_unit = cells[@unit_column_number[1]]
    asset.infrastructure_segment_unit_type = InfrastructureSegmentUnitType.find_by(name: cells[@unit_segment_column_number[1]])
    asset.from_location_name = cells[@from_location_column_number[1]]
    asset.to_location_name = cells[@to_location_column_number[1]]
    asset.fta_asset_class = FtaAssetClass.find_by(name: cells[@class_column_number[1]])
    asset.fta_type = FtaFacilityType.find_by(name: cells[@type_column_number[1]])

    asset_classification =  cells[@subtype_column_number[1]]
    asset.asset_subtype = AssetSubtype.find_by(name: asset_classification)

    infrastructure_segment_type = InfrastructureSegmentType.find_by(name: cells[@segment_type_column_number[1]])
    asset.infrastructure_segment_type = infrastructure_segment_type

    mainline = InfrastructureDivision.find_by(name: cells[@mainline_column_number[1]], organization_id: asset.organization.id)
    asset.infrastructure_division = mainline

    branch = InfrastructureSubdivision.find_by(name: cells[@mainline_column_number[1]])
    asset.infrastructure_subdivision = branch

    asset.num_tracks = cells[@number_of_tracks_column_number[1]]

    bridge_type = InfrastructureBridgeType.find_by(name: cells[@bridge_type_column_number[1]])
    asset.infrastructure_bridge_type = bridge_type
    asset.num_spans = cells[@number_of_spans_column_number[1]]
    asset.num_decks = cells[@number_of_decks_column_number[1]]

    crossing = InfrastructureCrossing.find_by(name: cells[@crossing_column_number[1]])
    asset.infrastructure_crossing = crossing

    asset.length = cells[@length_1_column_number[1]]
    asset.length_unit = cells[@length_unit_1_column_number[1]]
    asset.height = cells[@length_2_column_number[1]]
    asset.height_unit = cells[@length_unit_2_column_number[1]]
    asset.width = cells[@length_3_column_number[1]]
    asset.width_unit = cells[@length_unit_3_column_number[1]]

    if (cells[@direct_capital_responsibility_column_number[1]].upcase == 'YES')
      asset.pcnt_capital_responsibility = cells[@percent_capital_responsibility_column_number[1]].to_i
    end

    organization_with_shared_capital_responsitbility = cells[@organization_with_shared_capital_responsibility_column_number[1]]
    asset.shared_capital_responsibility_organization = organization_with_shared_capital_responsitbility

    priamry_mode_type_string = cells[@priamry_mode_column_number[1]].to_s.split(' - ')[1]
    asset.primary_fta_mode_type = FtaModeType.find_by(name: priamry_mode_type_string)
    asset.primary_fta_service_type = FtaServiceType.find_by(name: cells[@service_type_primary_mode_column_number[1]])
    asset.nearest_city = cells[@nearest_city_column_number[1]]
    asset.nearest_state = cells[@state_purchase_column_number[1]]

    land_owner_name = cells[@land_owner_column_number[1]]
    unless land_owner_name.nil?
      asset.land_ownership_organization = Organization.find_by(name: land_owner_name)
      if(land_owner_name == 'Other')
        asset.land_owner_name = cells[@land_owner_other_column_number[1]]
      end
    end

  end

  def set_events(asset, cells, columns)
    @add_processing_message = []

    unless(cells[@odometer_reading_column_number[1]].nil? || cells[@date_last_odometer_reading_column_number[1]].nil?)
      m = MileageUpdateEventLoader.new
      m.process(asset, [cells[@odometer_reading_column_number[1]], cells[@date_last_odometer_reading_column_number[1]]] )

      event = m.event
      if event.valid?
        event.save
      else
        @add_processing_message <<  [2, 'info', "Mileage Event for vehicle with Asset Tag #{asset.asset_tag} failed validation"]
      end

    end

    unless(cells[@condition_column_number[1]].nil? || cells[@date_last_condition_reading_column_number[1]].nil?)
      c = ConditionUpdateEventLoader.new
      c.process(asset, [cells[@condition_column_number[1]], cells[@date_last_condition_reading_column_number[1]]] )

      event = c.event
      if event.valid?
        event.save
      else
        @add_processing_message <<  [2, 'info', "Condition Event for vehicle with Asset Tag #{asset.asset_tag} failed validation"]
      end
    end

    unless cells[@rebuild_rehabilitation_total_cost_column_number[1]].nil? ||
           (cells[@rebuild_rehabilitation_extend_useful_life_miles_column_number[1]].nil? && cells[@rebuild_rehabilitation_extend_useful_life_months_column_number[1]].nil?) ||
           cells[@date_of_rebuild_rehabilitation_column_number[1]].nil?
      r = RebuildRehabilitationUpdateEventLoader.new
      cost = cells[ @rebuild_rehabilitation_total_cost_column_number[1]]
      months = cells[@rebuild_rehabilitation_extend_useful_life_months_column_number[1]]
      miles = cells[@rebuild_rehabilitation_extend_useful_life_miles_column_number[1]]
      r.process(asset, [cost, months, miles, cells[@date_of_rebuild_rehabilitation_column_number[1]]] )

      event = r.event
      if event.valid?
        event.save
      else
        @add_processing_message <<  [2, 'info', "Rebuild Event for vehicle with Asset Tag #{asset.asset_tag} failed validation"]
      end

    end


    unless(cells[@service_status_column_number[1]].nil? || cells[@date_of_last_service_status_column_number[1]].nil?)
      s= ServiceStatusUpdateEventLoader.new
      s.process(asset, [cells[@service_status_column_number[1]], cells[@date_of_last_service_status_column_number[1]]] )

      event = s.event
      if event.valid?
        event.save
      else
        @add_processing_message <<  [2, 'info', "Status Event for vehicle with Asset Tag #{asset.asset_tag} failed validation"]
      end

    end
  end

  def column_widths
    if @organization
      [20] + [30] + [20] * 48
    else
      [30] + [20] * 49
    end

  end

  def worksheet_name
    'Infrastructure - Guideways'
  end

  def set_initial_asset(cells)
    asset = Guideway.new

    asset_classification =  cells[@subtype_column_number[1]]
    asset.asset_subtype = AssetSubtype.find_by(name: asset_classification)

    asset.asset_tag = cells[@asset_id_column_number[1]]

    asset
  end

  def get_messages_to_process
    @add_processing_message
  end

  private

  def green_label_cells
    green_label_cells = [
        @agency_column_number,
        @asset_id_column_number,
        @line_from_line_column_number,
        @line_from_from_column_number,
        @line_to_line_column_number,
        @line_to_to_column_number,
        @unit_column_number,
        @class_column_number,
        @type_column_number,
        @subtype_column_number,
        @segment_type_column_number,
        @mainline_column_number,
        @branch_column_number,
        @direct_capital_responsibility_column_number,
        @percent_capital_responsibility_column_number,
        @organization_with_shared_capital_responsibility_column_number,
        @priamry_mode_column_number,
        @service_type_primary_mode_column_number,
        @service_status_column_number,
        @date_of_last_service_status_column_number
    ]
  end

  def white_label_cells
    white_label_cells = [
        @external_id_column_number,
        @description_column_number,
        @location_column_number,
        @from_location_column_number,
        @to_location_column_number,
        @number_of_tracks_column_number,
        @bridge_type_column_number,
        @number_of_spans_column_number,
        @number_of_decks_column_number,
        @crossing_column_number,
        @length_1_column_number,
        @length_unit_1_column_number,
        @length_2_column_number,
        @length_unit_2_column_number,
        @length_3_column_number,
        @length_unit_3_column_number,
        @nearest_city_column_number,
        @state_purchase_column_number,
        @land_owner_column_number,
        @infrastructure_owner_column_number,
        @condition_column_number,
        @date_last_condition_reading_column_number,
    ]
  end

  def grey_label_cells
    grey_label_cells = [
        @land_owner_other_column_number,
        @infrastructure_owner_other_column_number,
    ]
  end

  def initialize(*args)
    super

    # Define sections
    @identificaiton_and_classification_column_number = RubyXL::Reference.ref2ind('A1')
    @characteristics_bridges_only_column_number = RubyXL::Reference.ref2ind('T1')
    @characteristics_bridges_tunnels_column_number = RubyXL::Reference.ref2ind('V1')
    @geometry_column_number = RubyXL::Reference.ref2ind('X1')
    @operations_column_number = RubyXL::Reference.ref2ind('AG1')
    @registartion_column_number = RubyXL::Reference.ref2ind('AK1')
    @funding_column_number =  RubyXL::Reference.ref2ind('AD1')
    @initial_event_data_column_number = RubyXL::Reference.ref2ind('AO1')
    @last_known_column_number = RubyXL::Reference.ref2ind('BV1')

    # Define light green columns
    @agency_column_number = RubyXL::Reference.ref2ind('A2')
    @asset_id_column_number = RubyXL::Reference.ref2ind('B2')
    @external_id_column_number = RubyXL::Reference.ref2ind('C2')
    @description_column_number =  RubyXL::Reference.ref2ind('D2')
    @location_column_number = RubyXL::Reference.ref2ind('E2')
    @line_from_line_column_number = RubyXL::Reference.ref2ind('F2')
    @line_from_from_column_number = RubyXL::Reference.ref2ind('G2')
    @line_to_line_column_number = RubyXL::Reference.ref2ind('H2')
    @line_to_to_column_number = RubyXL::Reference.ref2ind('I2')
    @unit_column_number = RubyXL::Reference.ref2ind('J2')
    @unit_segment_column_number = RubyXL::Reference.ref2ind('K2')

    @from_location_column_number = RubyXL::Reference.ref2ind('L2')
    @to_location_column_number = RubyXL::Reference.ref2ind('M2')
    @class_column_number = RubyXL::Reference.ref2ind('N2')
    @type_column_number = RubyXL::Reference.ref2ind('O2')
    @subtype_column_number = RubyXL::Reference.ref2ind('P2')
    @segment_type_column_number = RubyXL::Reference.ref2ind('Q2')
    @mainline_column_number = RubyXL::Reference.ref2ind('R2')
    @branch_column_number = RubyXL::Reference.ref2ind('S2')
    @number_of_tracks_column_number = RubyXL::Reference.ref2ind('T2')
    @bridge_type_column_number = RubyXL::Reference.ref2ind('U2')
    @number_of_spans_column_number = RubyXL::Reference.ref2ind('V2')
    @number_of_decks_column_number = RubyXL::Reference.ref2ind('W2')
    @crossing_column_number = RubyXL::Reference.ref2ind('X2')
    @length_1_column_number = RubyXL::Reference.ref2ind('Y2')
    @length_unit_1_column_number = RubyXL::Reference.ref2ind('Z2')
    @length_2_column_number = RubyXL::Reference.ref2ind('AA2')
    @length_unit_2_column_number = RubyXL::Reference.ref2ind('AB2')
    @length_3_column_number = RubyXL::Reference.ref2ind('AC2')
    @length_unit_3_column_number = RubyXL::Reference.ref2ind('AD2')
    @direct_capital_responsibility_column_number =	RubyXL::Reference.ref2ind('AE2')
    @percent_capital_responsibility_column_number = RubyXL::Reference.ref2ind('AF2')
    @organization_with_shared_capital_responsibility_column_number = RubyXL::Reference.ref2ind('AG2')
    @priamry_mode_column_number = RubyXL::Reference.ref2ind('AH2')
    @service_type_primary_mode_column_number = RubyXL::Reference.ref2ind('AI2')
    @nearest_city_column_number = RubyXL::Reference.ref2ind('AJ2')
    @state_purchase_column_number = RubyXL::Reference.ref2ind('AK2')
    @land_owner_column_number = RubyXL::Reference.ref2ind('AL2')
    @land_owner_other_column_number = RubyXL::Reference.ref2ind('AM2')
    @infrastructure_owner_column_number = RubyXL::Reference.ref2ind('AN2')
    @infrastructure_owner_other_column_number = RubyXL::Reference.ref2ind('AO2')
    @condition_column_number = RubyXL::Reference.ref2ind('AP2')
    @date_last_condition_reading_column_number = RubyXL::Reference.ref2ind('AQ2')
    @service_status_column_number = RubyXL::Reference.ref2ind('AR2')
    @date_of_last_service_status_column_number = RubyXL::Reference.ref2ind('AS2')
  end


end